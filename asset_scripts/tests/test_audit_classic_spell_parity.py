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
        self.assertEqual(report["totals"]["supportedIdentities"], 148)
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
