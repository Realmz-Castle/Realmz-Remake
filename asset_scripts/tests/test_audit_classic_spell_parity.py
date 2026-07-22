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
        self.assertEqual(report["totals"]["supportedIdentities"], 65)
        self.assertEqual(
            report["totals"]["supportedIdentities"]
            + report["totals"]["remainingIdentities"],
            252,
        )
        self.assertEqual(report["validationErrors"], [])
        self.assertEqual(
            report["totals"]["genericImplementationLanes"],
            {
                "field-utility-review": 15,
                "no-source-effect-review": 1,
                "queued-area-engine-gap": 20,
            },
        )
        self.assertEqual(report, audit.build_report(inventory, matrix, native, legacy))

        matrix_by_id = {
            int(row["classicSpellId"]): row for row in matrix.get("spells", [])
        }
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

        flame_missile = matrix_by_id[1503]
        self.assertEqual(flame_missile["supportStatus"], "supported")
        self.assertEqual(
            flame_missile["classification"], "native-missile-specialization"
        )
        flame_resource = (
            REPO_ROOT / "src" / flame_missile["resource"].removeprefix("res://")
        )
        self.assertTrue(flame_resource.is_file(), flame_resource)


if __name__ == "__main__":
    unittest.main()
