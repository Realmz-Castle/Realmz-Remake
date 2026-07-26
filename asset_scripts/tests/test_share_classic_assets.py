import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "share_classic_assets.py"
SPEC = importlib.util.spec_from_file_location("share_classic_assets", SCRIPT_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


class ShareClassicAssetsTests(unittest.TestCase):
    def test_moves_only_cross_campaign_identical_tileset_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            campaigns = root / "Campaigns"
            shared = b"identical stock atlas"
            unique = [b"first unique metadata", b"second unique metadata"]
            for index, campaign_name in enumerate(["First (Classic)", "Second (Classic)"]):
                campaign = campaigns / campaign_name
                tileset = campaign / "Tilesets" / "landlook-0"
                tileset.mkdir(parents=True)
                (tileset / "landlook-0.png").write_bytes(shared)
                (tileset / "landlook-0.json").write_bytes(unique[index])
                (tileset / "tile_templates.json").write_bytes(b"{}\n")
                (campaign / "campaign.json").write_text(
                    json.dumps(
                        {
                            "format": MODULE.CAMPAIGN_FORMAT,
                            "id": f"campaign-{index}",
                            "name": campaign_name,
                        }
                    ),
                    encoding="utf-8",
                )
            external = campaigns / "Third Party"
            external.mkdir(parents=True)
            (external / "campaign.json").write_text(
                json.dumps({"format": MODULE.CAMPAIGN_FORMAT}),
                encoding="utf-8",
            )

            plan = MODULE.build_plan(root, 2)
            self.assertEqual(plan["summary"]["uniquePayloads"], 2)
            self.assertEqual(plan["summary"]["localFilesRemoved"], 4)
            self.assertEqual(
                plan["summary"]["grossBytesSaved"],
                len(shared) + len("{}\n"),
            )
            MODULE.apply_plan(plan)
            rerun = MODULE.build_plan(root, 2)
            self.assertEqual(rerun["summary"]["localFilesRemoved"], 0)
            self.assertEqual(
                rerun["summary"]["grossBytesSaved"],
                plan["summary"]["grossBytesSaved"],
            )

            digest = hashlib.sha256(shared).hexdigest()
            payload = (
                root
                / "ClassicAssets"
                / "sha256"
                / digest[:2]
                / f"{digest}.png"
            )
            self.assertEqual(payload.read_bytes(), shared)
            for campaign_name in ["First (Classic)", "Second (Classic)"]:
                campaign = campaigns / campaign_name
                self.assertFalse(
                    (campaign / "Tilesets/landlook-0/landlook-0.png").exists()
                )
                self.assertTrue(
                    (campaign / "Tilesets/landlook-0/landlook-0.json").exists()
                )
                manifest = json.loads(
                    (campaign / "campaign.json").read_text(encoding="utf-8")
                )
                paths = {
                    record["logicalPath"]
                    for record in manifest["sharedAssets"]["files"]
                }
                self.assertEqual(
                    paths,
                    {
                        "Tilesets/landlook-0/landlook-0.png",
                        "Tilesets/landlook-0/tile_templates.json",
                    },
                )
            self.assertFalse((external / "sharedAssets").exists())

    def test_dry_run_does_not_modify_campaigns(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            campaigns = root / "Campaigns"
            for index, campaign_name in enumerate(["First (Classic)", "Second (Classic)"]):
                campaign = campaigns / campaign_name
                tileset = campaign / "Tilesets" / "landlook-0"
                tileset.mkdir(parents=True)
                (tileset / "landlook-0.png").write_bytes(b"same")
                (campaign / "campaign.json").write_text(
                    json.dumps(
                        {
                            "format": MODULE.CAMPAIGN_FORMAT,
                            "id": f"campaign-{index}",
                            "name": campaign_name,
                        }
                    ),
                    encoding="utf-8",
                )

            plan = MODULE.build_plan(root, 2)

            self.assertEqual(plan["summary"]["localFilesRemoved"], 2)
            self.assertFalse((root / "ClassicAssets").exists())
            self.assertTrue(
                (
                    campaigns
                    / "First (Classic)"
                    / "Tilesets/landlook-0/landlook-0.png"
                ).exists()
            )


if __name__ == "__main__":
    unittest.main()
