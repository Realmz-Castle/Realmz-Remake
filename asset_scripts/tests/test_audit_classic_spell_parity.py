import copy
import sys
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "asset_scripts"))

import audit_classic_spell_parity as audit  # noqa: E402


def spell_record(
    spell_id: int,
    *,
    name: str = "Test Spell",
    special: int = 0,
    cost: int = 5,
    sound: int = 1,
    queue_icon: int = 0,
) -> dict:
    record = {field: 0 for field in audit.MECHANIC_FIELDS}
    record.update(
        {
            "range1": 4,
            "cost": cost,
            "powerDamage1": 2,
            "powerDamage2": 4,
            "special": special,
            "damageType": 6,
            "spellClass": 4,
            "inCombat": 1,
            "sound1": sound,
            "sound2": 2,
            "queueIcon": queue_icon,
            "spellLook1": 4,
            "spellLook2": 5,
        }
    )
    return {
        "packedSpellId": spell_id,
        "displayName": name,
        "casterClass": "Sorcerer",
        "level": 1,
        "slot": spell_id % 100,
        "recordShape": "generic" if special == 0 else "special-behavior",
        "sourceRecord": {
            "sourceFile": "Data S",
            "recordIndex": spell_id - 1101,
            "byteOffset": (spell_id - 1101) * 30,
            "byteLength": 30,
        },
        "record": record,
    }


class ClassicSpellParityAuditTests(unittest.TestCase):
    def test_generic_records_are_split_by_runtime_mechanism(self) -> None:
        direct = spell_record(1101)
        self.assertEqual(audit.generic_implementation_lane(direct), "direct-damage")

        queued = spell_record(1102, queue_icon=3)
        self.assertEqual(
            audit.generic_implementation_lane(queued), "queued-area-engine-gap"
        )

        utility = spell_record(1103, cost=-1)
        self.assertEqual(
            audit.generic_implementation_lane(utility), "field-utility-review"
        )

        missile = spell_record(1104)
        missile["record"]["spellClass"] = 9
        self.assertEqual(
            audit.generic_implementation_lane(missile), "missile-specialization"
        )

        no_effect = spell_record(1105)
        for field in ("damage1", "damage2", "powerDamage1", "powerDamage2"):
            no_effect["record"][field] = 0
        self.assertEqual(
            audit.generic_implementation_lane(no_effect), "no-source-effect-review"
        )

    def test_mechanic_family_ignores_presentation_only_changes(self) -> None:
        first = spell_record(1101, sound=1)
        second = spell_record(1102, sound=99)
        self.assertEqual(audit.mechanic_family_id(first), audit.mechanic_family_id(second))

        changed_cost = copy.deepcopy(second)
        changed_cost["record"]["cost"] = 6
        self.assertNotEqual(
            audit.mechanic_family_id(first), audit.mechanic_family_id(changed_cost)
        )

    def test_legacy_hint_comparison_never_confers_support(self) -> None:
        spell = spell_record(1101)
        legacy = {
            "hints": {
                "rangeAtPower1": {"expression": "4", "valueAtPower1": 4},
                "spellPointCostAtPower1": {
                    "expression": "_power * 5",
                    "valueAtPower1": 5,
                },
            }
        }
        comparison = audit.compare_legacy_hints(spell, legacy)
        self.assertEqual(comparison["status"], "matches-parsed-fields")

        report = audit.build_report(
            {"spells": [spell]},
            {"spells": []},
            [],
            [legacy | {"path": "old.gd", "name": "Test Spell"}],
        )
        self.assertEqual(report["spells"][0]["supportStatus"], "unclassified")
        self.assertEqual(
            report["spells"][0]["coverageStatus"],
            "generic-implementation-candidate",
        )

    def test_supported_family_extension_is_a_review_candidate(self) -> None:
        supported = spell_record(1101, name="First Name", sound=1)
        candidate = spell_record(1102, name="Second Name", sound=2)
        matrix = {
            "spells": [
                {
                    "classicSpellId": 1101,
                    "supportStatus": "supported",
                    "classification": "native-direct",
                    "resource": "res://shared_assets/spells/test_spell.gd",
                }
            ]
        }
        native = [
            {
                "path": "src/shared_assets/spells/test_spell.gd",
                "name": "First Name",
                "classicSpellIds": [1101],
                "extends": "Spell",
            }
        ]
        report = audit.build_report({"spells": [supported, candidate]}, matrix, native, [])
        family = report["mechanicFamilies"][0]
        self.assertEqual(family["supportedSpellIds"], [1101])
        self.assertEqual(family["remainingSpellIds"], [1102])
        self.assertEqual(
            family["recommendedAction"], "review-supported-family-extension"
        )
        self.assertEqual(report["totals"]["remainingIdentitiesInSupportedFamilies"], 1)

    def test_supported_resource_mismatch_is_a_validation_error(self) -> None:
        spell = spell_record(1101)
        matrix = {
            "spells": [
                {
                    "classicSpellId": 1101,
                    "supportStatus": "supported",
                    "resource": "res://shared_assets/spells/missing.gd",
                }
            ]
        }
        report = audit.build_report({"spells": [spell]}, matrix, [], [])
        self.assertEqual(report["totals"]["validationErrors"], 2)
        self.assertEqual(report["spells"][0]["coverageStatus"], "support-resource-mismatch")

    def test_repository_inputs_are_structurally_valid(self) -> None:
        inventory_path = (
            REPO_ROOT / "src/scripts/classic_runtime/classic_core_spell_inventory.json"
        )
        matrix_path = (
            REPO_ROOT / "src/scripts/classic_runtime/classic_spell_support_matrix.json"
        )
        inventory = audit._load_json(inventory_path)
        matrix = audit._load_json(matrix_path)
        native = audit.read_native_resources(
            REPO_ROOT / "src/shared_assets/spells", REPO_ROOT
        )
        legacy = audit.read_legacy_scripts(
            REPO_ROOT / "asset_scripts/spell_scripts", REPO_ROOT
        )
        report = audit.build_report(inventory, matrix, native, legacy)
        self.assertEqual(report["totals"]["identities"], 252)
        self.assertEqual(report["totals"]["supportedIdentities"], 252)
        self.assertEqual(
            report["totals"]["supportedIdentities"]
            + report["totals"]["remainingIdentities"],
            252,
        )
        self.assertEqual(report["validationErrors"], [])
        self.assertEqual(
            report["totals"]["genericImplementationLanes"],
            {},
        )
        self.assertEqual(report, audit.build_report(inventory, matrix, native, legacy))

        matrix_by_id = {
            int(row["classicSpellId"]): row for row in matrix.get("spells", [])
        }
        party_conditions_by_spell = {
            1105: 6,
            1202: 3,
            1205: 6,
            1312: 1,
            1512: 4,
            1612: 8,
            2104: 6,
            2202: 3,
            2312: 2,
            2710: 7,
            3107: 2,
            3203: 3,
            3204: 2,
            3611: 7,
        }
        for spell_id, expected_condition in party_conditions_by_spell.items():
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-party-condition"
            )
            self.assertEqual(row["behavior"]["conditionIndex"], expected_condition)
            self.assertEqual(
                row["behavior"]["conditionDecay"],
                "one-per-combat-round-or-game-hour",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        helpless_spell_ids = {1710, 2310, 2405, 2510, 2610, 3209, 3707}
        for spell_id in helpless_spell_ids:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertIn(
                row["classification"],
                {"native-special-helpless", "native-special-queued-helpless"},
            )
            self.assertEqual(row["behavior"]["conditionIndex"], 1)
            self.assertEqual(row["behavior"]["saveMode"], "negate-condition")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {1311, 2311}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-queued-slow"
            )
            self.assertEqual(row["behavior"]["conditionIndex"], 6)
            self.assertEqual(row["behavior"]["saveMode"], "negate-condition")
            self.assertEqual(row["behavior"]["actionCount"], "unchanged-source-behavior")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        tangle_weed = matrix_by_id[2412]
        self.assertEqual(tangle_weed["supportStatus"], "supported")
        self.assertEqual(
            tangle_weed["classification"], "native-special-queued-tangled"
        )
        self.assertEqual(tangle_weed["behavior"]["conditionIndex"], 2)
        self.assertEqual(tangle_weed["behavior"]["rawSpecial"], 253)
        self.assertEqual(tangle_weed["behavior"]["resolvedSpecial"], 3)
        self.assertEqual(tangle_weed["behavior"]["saveMode"], "none")
        self.assertEqual(tangle_weed["behavior"]["resistance"], "none-force-affect")
        tangle_resource = (
            REPO_ROOT / "src" / tangle_weed["resource"].removeprefix("res://")
        )
        self.assertTrue(tangle_resource.is_file(), tangle_resource)
        destroy_trap = matrix_by_id[3605]
        self.assertEqual(destroy_trap["supportStatus"], "supported")
        self.assertEqual(
            destroy_trap["classification"], "native-special-rogue-destroy-trap"
        )
        self.assertEqual(destroy_trap["behavior"]["rawSpecial"], 65)
        self.assertEqual(
            destroy_trap["behavior"]["disarmChance"],
            "data-td2-disarm-modifier-times-power",
        )
        self.assertEqual(
            destroy_trap["behavior"]["disarmFailure"],
            "show-disarm-failure-then-fall-through-to-open-lock",
        )
        self.assertEqual(
            destroy_trap["behavior"]["spellAndItemPaths"],
            "native-cast-scroll-and-type-20-item",
        )
        self.assertEqual(
            destroy_trap["behavior"]["zeroResult"],
            "exit-encounter-without-reopening-response-picker",
        )
        destroy_trap_resource = (
            REPO_ROOT / "src" / destroy_trap["resource"].removeprefix("res://")
        )
        self.assertTrue(destroy_trap_resource.is_file(), destroy_trap_resource)
        open_lock = matrix_by_id[1109]
        self.assertEqual(open_lock["supportStatus"], "supported")
        self.assertEqual(
            open_lock["classification"], "native-special-rogue-open-lock"
        )
        self.assertEqual(open_lock["behavior"]["rawSpecial"], 70)
        self.assertEqual(
            open_lock["behavior"]["openLockChance"],
            "data-td2-open-lock-modifier-times-power",
        )
        self.assertEqual(
            open_lock["behavior"]["chanceSnapshot"],
            "before-armed-trap-damage-or-spell-resolution",
        )
        self.assertEqual(
            open_lock["behavior"]["spellAndItemPaths"],
            "native-cast-scroll-and-type-20-item",
        )
        open_lock_resource = (
            REPO_ROOT / "src" / open_lock["resource"].removeprefix("res://")
        )
        self.assertTrue(open_lock_resource.is_file(), open_lock_resource)
        sleepwalk = matrix_by_id[1412]
        self.assertEqual(sleepwalk["supportStatus"], "supported")
        self.assertEqual(
            sleepwalk["classification"], "native-special-party-fatigue"
        )
        self.assertEqual(sleepwalk["behavior"]["rawSpecial"], 68)
        self.assertEqual(
            sleepwalk["behavior"]["effect"],
            "set-remake-party-fatigue-to-one",
        )
        self.assertEqual(sleepwalk["behavior"]["powerScaling"], "none")
        self.assertEqual(sleepwalk["behavior"]["targetSelection"], "none")
        sleepwalk_resource = (
            REPO_ROOT / "src" / sleepwalk["resource"].removeprefix("res://")
        )
        self.assertTrue(sleepwalk_resource.is_file(), sleepwalk_resource)
        undead_spell = matrix_by_id[3504]
        self.assertEqual(undead_spell["supportStatus"], "supported")
        self.assertEqual(
            undead_spell["classification"], "native-special-undead-turning"
        )
        self.assertEqual(undead_spell["behavior"]["rawSpecial"], 90)
        self.assertEqual(undead_spell["behavior"]["saveIndex"], 7)
        self.assertEqual(
            undead_spell["behavior"]["turningStrength"],
            "five-times-power-plus-three-times-caster-level",
        )
        self.assertEqual(
            undead_spell["behavior"]["experience"], "none-from-spell"
        )
        undead_spell_resource = (
            REPO_ROOT
            / "src"
            / undead_spell["resource"].removeprefix("res://")
        )
        self.assertTrue(undead_spell_resource.is_file(), undead_spell_resource)
        for spell_id in {2203, 3407}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-spellcasting-block"
            )
            self.assertEqual(row["behavior"]["conditionIndex"], 5)
            self.assertEqual(row["behavior"]["saveMode"], "negate-condition")
            self.assertEqual(
                row["behavior"]["effect"], "prevent-spellcasting-only"
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        magic_aura = matrix_by_id[2106]
        self.assertEqual(magic_aura["supportStatus"], "supported")
        self.assertEqual(
            magic_aura["classification"], "native-special-magic-aura"
        )
        self.assertEqual(magic_aura["behavior"]["conditionIndex"], 4)
        self.assertEqual(magic_aura["behavior"]["targetType"], "all-friendly")
        self.assertEqual(
            magic_aura["behavior"]["effect"],
            "add-five-percentage-points-to-physical-attack-and-defense",
        )
        magic_aura_resource = (
            REPO_ROOT / "src" / magic_aura["resource"].removeprefix("res://")
        )
        self.assertTrue(magic_aura_resource.is_file(), magic_aura_resource)
        for spell_id in {1607, 1709, 2507, 2707}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-charm")
            self.assertEqual(row["behavior"]["duration"], "battle")
            self.assertEqual(row["behavior"]["saveMode"], "none")
            self.assertEqual(row["behavior"]["preResistance"], "classic-charm")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        summon_tiers = {
            1502: 1,
            1602: 2,
            1702: 3,
            2604: 3,
            2704: 5,
            3201: 1,
            3304: 2,
            3403: 3,
            3502: 4,
            3604: 5,
            3701: 6,
        }
        for spell_id, expected_tier in summon_tiers.items():
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertIn(
                row["classification"],
                {"native-special-summon", "native-corrected-source-defect"},
            )
            self.assertEqual(row["behavior"]["special"], 58)
            self.assertEqual(row["behavior"]["summonTier"], expected_tier)
            self.assertEqual(row["behavior"]["monsterSlotLimit"], 100)
            self.assertEqual(row["behavior"]["lifetime"], "battle")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id, force_affect_code in {1304: 4, 2302: 3, 3503: 4}.items():
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-dispel")
            self.assertEqual(row["behavior"]["special"], 61)
            self.assertEqual(
                row["behavior"]["effect"], "clear-positive-duration-conditions"
            )
            self.assertEqual(row["behavior"]["permanentConditions"], "preserve")
            self.assertEqual(row["behavior"]["partyAllegiance"], "restore-base")
            self.assertEqual(row["behavior"]["monsterAllegiance"], "preserve")
            self.assertEqual(row["behavior"]["forceAffectCode"], force_affect_code)
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id, expected_cost in {1410: 6, 2309: 30}.items():
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-curse-removal"
            )
            self.assertEqual(row["behavior"]["special"], 62)
            self.assertEqual(row["behavior"]["conditionIndex"], 3)
            self.assertEqual(
                row["behavior"]["effect"],
                "clear-cursed-condition-and-unequip-all-equipped-cursed-items",
            )
            self.assertEqual(
                row["behavior"]["itemSelection"],
                "all-equipped-cursed-items-per-target",
            )
            self.assertEqual(row["behavior"]["inventoryMutation"], "preserve-items")
            self.assertEqual(row["behavior"]["costPerPower"], expected_cost)
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {1106, 3307}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-identify-items"
            )
            self.assertEqual(row["behavior"]["power"], "fixed-one")
            self.assertEqual(row["behavior"]["fixedCost"], 25)
            self.assertEqual(row["behavior"]["saveMode"], "none")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2601, 2701, 3606, 3609}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-lethal")
            self.assertEqual(row["behavior"]["special"], 49)
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        self.assertEqual(
            matrix_by_id[2601]["behavior"]["preResistance"],
            "opposed-target-level-versus-caster-level",
        )
        self.assertEqual(
            matrix_by_id[3609]["behavior"]["saveMode"],
            "half-fallback-damage",
        )
        for spell_id in {3612, 3705}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-transformation"
            )
            self.assertEqual(row["behavior"]["special"], 46)
            self.assertEqual(
                row["behavior"]["formPool"],
                "active-classic-bestiary-with-native-fallback",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        self.assertEqual(
            matrix_by_id[3705]["behavior"]["targetType"],
            "power-scaled-area",
        )
        for spell_id in {1208, 1509, 2305, 2511, 3106, 3309}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-phase")
            self.assertEqual(row["behavior"]["special"], 56)
            self.assertEqual(row["behavior"]["saveMode"], "none")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        self.assertEqual(
            matrix_by_id[1208]["behavior"]["remainingActions"],
            "exhausted",
        )
        self.assertEqual(
            matrix_by_id[1509]["behavior"]["remainingActions"],
            "preserved-after-casting-action",
        )
        weakness = matrix_by_id[2612]
        self.assertEqual(weakness["supportStatus"], "supported")
        self.assertEqual(
            weakness["classification"], "native-corrected-source-defect"
        )
        self.assertEqual(weakness["behavior"]["targetType"], "ray")
        self.assertEqual(
            weakness["behavior"]["sourceDefect"],
            "drain-range-stored-in-duration-fields",
        )
        improved_drain = matrix_by_id[2703]
        self.assertEqual(improved_drain["supportStatus"], "supported")
        self.assertEqual(
            improved_drain["classification"], "native-special-adapter"
        )
        self.assertEqual(
            improved_drain["behavior"]["targetType"],
            "power-selected-creatures",
        )
        for row in [weakness, improved_drain]:
            self.assertEqual(row["behavior"]["special"], 60)
            self.assertEqual(row["behavior"]["saveMode"], "half-effect")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {1409, 3312}:
            surge = matrix_by_id[spell_id]
            self.assertEqual(surge["supportStatus"], "supported")
            self.assertEqual(
                surge["classification"],
                "native-special-spell-point-surge",
            )
            self.assertEqual(surge["behavior"]["special"], 59)
            self.assertEqual(surge["behavior"]["saveMode"], "none")
            self.assertEqual(
                surge["behavior"]["playerMaximum"], "max-spell-points"
            )
            self.assertEqual(
                surge["behavior"]["monsterMaximum"], "uncapped-like-classic"
            )
            resource_path = (
                REPO_ROOT / "src" / surge["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        shield_from_hits_ids = {1111, 2112, 3212, 3406}
        for spell_id in shield_from_hits_ids:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-shield-from-hits"
            )
            self.assertEqual(row["behavior"]["conditionIndex"], 7)
            self.assertEqual(
                row["behavior"]["effect"],
                "subtract-two-percentage-points-per-condition-point-from-melee-hit-chance",
            )
            self.assertEqual(
                row["behavior"]["evasionTranslationPerConditionPoint"], 0.4
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2210, 3508}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"],
                "native-special-projectile-protection",
            )
            self.assertEqual(row["behavior"]["conditionIndex"], 8)
            self.assertEqual(
                row["behavior"]["effect"],
                "complete-immunity-to-class-9-missile-spells",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        queued_spell_ids = {
            1308, 1309, 1407, 1608, 1610, 1611, 1704, 1711, 1712, 2407,
            2501, 2508, 2512, 2607, 3210, 3310, 3509, 3512, 3607, 3702,
        }
        for spell_id in queued_spell_ids:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-queued-area")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)

        for spell_id in {1506, 1604, 1705, 2105, 2207, 2404, 2505}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-healing")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2709, 3706}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-regeneration")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2204, 2205, 2206, 2602, 3206, 3405}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-condition-cure"
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2606, 3708}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-revival")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        for spell_id in {2107, 2108, 2303, 2308, 3101, 3103, 3402, 3412}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
        psi_shield = matrix_by_id[2308]
        self.assertEqual(
            psi_shield["classification"], "native-special-damage-protection"
        )
        self.assertEqual(psi_shield["behavior"]["effect"], "halve-mental-damage")
        self.assertFalse(psi_shield["behavior"]["charmProtection"])
        super_brawn = matrix_by_id[2212]
        self.assertEqual(super_brawn["supportStatus"], "supported")
        self.assertEqual(super_brawn["classification"], "native-special-strong")
        self.assertEqual(
            super_brawn["behavior"]["accuracyTranslation"],
            "plus-3-remake-stat-points",
        )
        super_brawn_resource = (
            REPO_ROOT / "src" / super_brawn["resource"].removeprefix("res://")
        )
        self.assertTrue(super_brawn_resource.is_file(), super_brawn_resource)
        protection_from_foe_resources = set()
        for spell_id in {1210, 2409}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(
                row["classification"], "native-special-protection-from-foe"
            )
            self.assertEqual(
                row["behavior"]["effect"],
                "plus-10-hit-chance-against-evil-minus-10-for-evil-attacker",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
            protection_from_foe_resources.add(row["resource"])
        self.assertEqual(len(protection_from_foe_resources), 2)
        speedy_resources = set()
        for spell_id in {1302, 2401}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-speedy")
            self.assertEqual(
                row["behavior"]["actionTranslation"],
                "plus-4-classic-half-attacks-equals-plus-2-remake-actions",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
            speedy_resources.add(row["resource"])
        self.assertEqual(len(speedy_resources), 2)
        invisible_resources = set()
        for spell_id in {1206, 1708, 2208, 2509}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-invisible")
            self.assertEqual(
                row["behavior"]["evasionTranslation"],
                "plus-2-remake-stat-points",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
            invisible_resources.add(row["resource"])
        self.assertEqual(len(invisible_resources), 4)
        animation_resources = set()
        for spell_id in {2410, 3610}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-animation")
            self.assertEqual(row["behavior"]["restoredHealth"], "floor-max-health-divided-by-four")
            self.assertEqual(row["behavior"]["healing"], "normal")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
            animation_resources.add(row["resource"])
        self.assertEqual(len(animation_resources), 2)
        petrification_resources = set()
        for spell_id in {2608, 3411}:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-special-petrification")
            self.assertEqual(row["behavior"]["conditionIndex"], 26)
            self.assertEqual(row["behavior"]["healing"], "blocked-until-flesh")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)
            petrification_resources.add(row["resource"])
        self.assertEqual(len(petrification_resources), 2)
        blind = matrix_by_id[2402]
        self.assertEqual(blind["supportStatus"], "supported")
        self.assertEqual(blind["classification"], "native-special-blindness")
        self.assertEqual(blind["behavior"]["conditionIndex"], 27)
        self.assertEqual(
            blind["behavior"]["accuracyEvasionTranslation"],
            "minus-3-remake-stat-points-equals-minus-15-percentage-points",
        )
        self.assertEqual(
            blind["behavior"]["legacyHealthSideEffect"],
            "omit-stale-disease-path-one-point-heal",
        )
        blind_resource = (
            REPO_ROOT / "src" / blind["resource"].removeprefix("res://")
        )
        self.assertTrue(blind_resource.is_file(), blind_resource)
        for spell_id in {2304, 2502}:
            disease = matrix_by_id[spell_id]
            self.assertEqual(disease["supportStatus"], "supported")
            self.assertEqual(disease["classification"], "native-special-disease")
            self.assertEqual(disease["behavior"]["conditionIndex"], 28)
            disease_resource = (
                REPO_ROOT / "src" / disease["resource"].removeprefix("res://")
            )
            self.assertTrue(disease_resource.is_file(), disease_resource)
        self.assertEqual(
            matrix_by_id[2304]["behavior"]["sharedDurationRoll"],
            "once-per-cast",
        )
        self.assertEqual(
            matrix_by_id[2502]["behavior"]["savedCondition"],
            "full-permanent-disease",
        )
        poison = matrix_by_id[2408]
        self.assertEqual(poison["supportStatus"], "supported")
        self.assertEqual(poison["classification"], "native-special-poison")
        self.assertEqual(poison["behavior"]["conditionIndex"], 9)
        self.assertEqual(poison["behavior"]["savedCondition"], "full-permanent-poison")
        poison_resource = (
            REPO_ROOT / "src" / poison["resource"].removeprefix("res://")
        )
        self.assertTrue(poison_resource.is_file(), poison_resource)
        for spell_id in {1508, 1707, 2406, 2603, 3507, 3703}:
            deflector = matrix_by_id[spell_id]
            self.assertEqual(deflector["supportStatus"], "supported")
            self.assertEqual(
                deflector["classification"], "native-special-spell-deflection"
            )
            self.assertEqual(deflector["behavior"]["conditionIndex"], 30)
            self.assertEqual(
                deflector["behavior"]["reflectionOrder"],
                "before-magic-resistance-and-save",
            )
            self.assertFalse(deflector["behavior"]["recursiveReflection"])
            deflector_resource = (
                REPO_ROOT
                / "src"
                / deflector["resource"].removeprefix("res://")
            )
            self.assertTrue(deflector_resource.is_file(), deflector_resource)
        for spell_id in {1406, 1606, 2307, 2506, 3408, 3608}:
            deflector = matrix_by_id[spell_id]
            self.assertEqual(deflector["supportStatus"], "supported")
            self.assertEqual(
                deflector["classification"], "native-special-attack-deflection"
            )
            self.assertEqual(deflector["behavior"]["conditionIndex"], 31)
            self.assertEqual(
                deflector["behavior"]["reflectionOrder"],
                "after-original-hit-before-damage",
            )
            self.assertFalse(deflector["behavior"]["secondAccuracyRoll"])
            self.assertFalse(deflector["behavior"]["additionalActionCost"])
            deflector_resource = (
                REPO_ROOT
                / "src"
                / deflector["resource"].removeprefix("res://")
            )
            self.assertTrue(deflector_resource.is_file(), deflector_resource)
        for spell_id in {1102, 2503, 3104, 3305}:
            attack_bonus = matrix_by_id[spell_id]
            self.assertEqual(attack_bonus["supportStatus"], "supported")
            self.assertEqual(
                attack_bonus["classification"], "native-special-attack-bonus"
            )
            self.assertEqual(attack_bonus["behavior"]["conditionIndex"], 32)
            self.assertEqual(
                attack_bonus["behavior"]["conditionDecay"],
                "one-per-combat-round-or-game-hour",
            )
            self.assertEqual(
                attack_bonus["behavior"]["sharedDurationRoll"], "once-per-cast"
            )
            attack_bonus_resource = (
                REPO_ROOT
                / "src"
                / attack_bonus["resource"].removeprefix("res://")
            )
            self.assertTrue(
                attack_bonus_resource.is_file(), attack_bonus_resource
            )
        for spell_id in {1510, 3510}:
            power_gather = matrix_by_id[spell_id]
            self.assertEqual(power_gather["supportStatus"], "supported")
            self.assertEqual(
                power_gather["classification"],
                "native-special-spell-point-regeneration",
            )
            self.assertEqual(power_gather["behavior"]["conditionIndex"], 33)
            self.assertEqual(
                power_gather["behavior"]["conditionDecay"],
                "one-per-combat-round-or-game-hour",
            )
            self.assertEqual(power_gather["behavior"]["maximumSpellPoints"], "clamp")
            self.assertEqual(
                power_gather["behavior"]["correctedIntent"],
                "monster-source-branch-reads-adjacent-energy-drain-slot",
            )
            power_gather_resource = (
                REPO_ROOT
                / "src"
                / power_gather["resource"].removeprefix("res://")
            )
            self.assertTrue(power_gather_resource.is_file(), power_gather_resource)
        for spell_id in {1511, 2711, 3511}:
            energy_drain = matrix_by_id[spell_id]
            self.assertEqual(energy_drain["supportStatus"], "supported")
            self.assertEqual(
                energy_drain["classification"],
                "native-special-spell-point-drain",
            )
            self.assertEqual(energy_drain["behavior"]["conditionIndex"], 34)
            self.assertEqual(
                energy_drain["behavior"]["playerOrder"],
                "drain-before-condition-decrement",
            )
            self.assertEqual(
                energy_drain["behavior"]["monsterOrder"],
                "condition-decrement-before-drain",
            )
            self.assertEqual(
                energy_drain["behavior"]["minimumSpellPoints"], "clamp-zero"
            )
            energy_drain_resource = (
                REPO_ROOT
                / "src"
                / energy_drain["resource"].removeprefix("res://")
            )
            self.assertTrue(energy_drain_resource.is_file(), energy_drain_resource)
        self.assertEqual(
            matrix_by_id[2711]["behavior"]["saveMode"],
            "half-immediate-damage-condition-still-applies",
        )
        for spell_id in {1301, 1403, 2702, 3302}:
            absorption = matrix_by_id[spell_id]
            self.assertEqual(absorption["supportStatus"], "supported")
            self.assertEqual(
                absorption["classification"],
                "native-special-spell-point-absorption",
            )
            self.assertEqual(absorption["behavior"]["conditionIndex"], 35)
            self.assertEqual(
                absorption["behavior"]["absorptionOrder"],
                "after-spell-reflection-before-magic-resistance-and-save",
            )
            self.assertFalse(absorption["behavior"]["reflectedCastAbsorption"])
            self.assertEqual(
                absorption["behavior"]["conditionDecay"],
                "one-per-combat-round-or-game-hour",
            )
            absorption_resource = (
                REPO_ROOT
                / "src"
                / absorption["resource"].removeprefix("res://")
            )
            self.assertTrue(absorption_resource.is_file(), absorption_resource)
        for spell_id in {1207, 2209}:
            hindrance = matrix_by_id[spell_id]
            self.assertEqual(hindrance["supportStatus"], "supported")
            self.assertEqual(
                hindrance["classification"],
                "native-special-attack-hindrance",
            )
            self.assertEqual(hindrance["behavior"]["conditionIndex"], 36)
            self.assertEqual(
                hindrance["behavior"]["effect"],
                "subtract-remaining-condition-from-melee-and-ranged-accuracy",
            )
            self.assertEqual(hindrance["behavior"]["saveIndex"], 5)
            self.assertEqual(
                hindrance["behavior"]["sharedDurationRoll"], "once-per-cast"
            )
            hindrance_resource = (
                REPO_ROOT
                / "src"
                / hindrance["resource"].removeprefix("res://")
            )
            self.assertTrue(hindrance_resource.is_file(), hindrance_resource)
        shrink_foe = matrix_by_id[3109]
        self.assertEqual(shrink_foe["supportStatus"], "supported")
        self.assertEqual(
            shrink_foe["classification"],
            "native-special-defense-hindrance",
        )
        self.assertEqual(shrink_foe["behavior"]["conditionIndex"], 37)
        self.assertEqual(
            shrink_foe["behavior"]["effect"],
            "subtract-remaining-condition-from-melee-and-ranged-evasion",
        )
        self.assertEqual(shrink_foe["behavior"]["saveMode"], "none")
        self.assertEqual(shrink_foe["behavior"]["resistance"], "none")
        self.assertEqual(
            shrink_foe["behavior"]["sharedDurationRoll"], "once-per-cast"
        )
        shrink_foe_resource = (
            REPO_ROOT
            / "src"
            / shrink_foe["resource"].removeprefix("res://")
        )
        self.assertTrue(shrink_foe_resource.is_file(), shrink_foe_resource)
        parameterized_damage_ids = {
            1601,
            1703,
            2705,
            3108,
            3205,
            3501,
            3601,
            3602,
            3710,
        }
        for spell_id in parameterized_damage_ids:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-parameterized-damage")
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)

        encounter_response_ids = {
            1107,
            1112,
            1201,
            1305,
            1609,
            2504,
            2609,
            2611,
            3111,
            3112,
            3306,
            3404,
            3410,
            3709,
            3711,
        }
        for spell_id in encounter_response_ids:
            row = matrix_by_id[spell_id]
            self.assertEqual(row["supportStatus"], "supported")
            self.assertEqual(row["classification"], "native-encounter-response")
            self.assertEqual(
                row["behavior"]["learnedSpellIdentity"],
                "exact-id-campaign-entry-save-load",
            )
            resource_path = (
                REPO_ROOT / "src" / row["resource"].removeprefix("res://")
            )
            self.assertTrue(resource_path.is_file(), resource_path)

        flame_missile = matrix_by_id[1503]
        self.assertEqual(flame_missile["supportStatus"], "supported")
        self.assertEqual(
            flame_missile["classification"], "native-missile-specialization"
        )
        flame_resource = (
            REPO_ROOT / "src" / flame_missile["resource"].removeprefix("res://")
        )
        self.assertTrue(flame_resource.is_file(), flame_resource)

        stun = matrix_by_id[2712]
        self.assertEqual(stun["supportStatus"], "supported")
        self.assertEqual(stun["classification"], "native-corrected-source-defect")
        stun_resource = REPO_ROOT / "src" / stun["resource"].removeprefix("res://")
        self.assertTrue(stun_resource.is_file(), stun_resource)


if __name__ == "__main__":
    unittest.main()
