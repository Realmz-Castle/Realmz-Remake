import json
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "asset_scripts"))

import audit_classic_spell_parity as audit  # noqa: E402
import scaffold_classic_damage_spells as scaffold  # noqa: E402


class ClassicDamageSpellScaffoldTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.inventory = audit._load_json(
            REPO_ROOT / "src/scripts/classic_runtime/classic_core_spell_inventory.json"
        )
        cls.report = audit.build_report(
            cls.inventory,
            audit._load_json(
                REPO_ROOT / "src/scripts/classic_runtime/classic_spell_support_matrix.json"
            ),
            audit.read_native_resources(
                REPO_ROOT / "src/shared_assets/spells", REPO_ROOT
            ),
            audit.read_legacy_scripts(
                REPO_ROOT / "asset_scripts/spell_scripts", REPO_ROOT
            ),
        )

    def test_repository_scaffold_is_the_nine_audited_damage_records(self) -> None:
        manifest, scripts = scaffold.build_scaffold(self.inventory, self.report)
        self.assertEqual(manifest["count"], 9)
        self.assertEqual(
            [entry["classicSpellId"] for entry in manifest["entries"]],
            [1601, 1703, 2705, 3108, 3205, 3501, 3601, 3602, 3710],
        )
        self.assertEqual(len(scripts), 9)
        self.assertIn("configure_core_damage_spell(2705)", scripts[
            "classic_core_2705_meteor_shower.gd"
        ])
        self.assertTrue(all(
            entry["matrixDraft"]["supportStatus"] == "review-required"
            for entry in manifest["entries"]
        ))
        for file_name, source in scripts.items():
            checked_in = REPO_ROOT / "src/shared_assets/spells" / file_name
            self.assertEqual(checked_in.read_text(encoding="utf-8"), source)

    def test_output_is_byte_deterministic(self) -> None:
        manifest, scripts = scaffold.build_scaffold(self.inventory, self.report)
        with tempfile.TemporaryDirectory() as first, tempfile.TemporaryDirectory() as second:
            first_path = Path(first)
            second_path = Path(second)
            scaffold.write_scaffold(first_path, manifest, scripts)
            scaffold.write_scaffold(second_path, manifest, scripts)
            first_files = {
                path.name: path.read_bytes() for path in sorted(first_path.iterdir())
            }
            second_files = {
                path.name: path.read_bytes() for path in sorted(second_path.iterdir())
            }
            self.assertEqual(first_files, second_files)
            parsed = json.loads(first_files["review-manifest.json"])
            self.assertEqual(parsed["count"], 9)


if __name__ == "__main__":
    unittest.main()
