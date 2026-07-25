class_name ClassicKnownDataCorrections
extends RefCounted

const MITHRIL_VAULT_CAMPAIGN_ID := "scenario-mithril-vault"


static func spell_reference(
	campaign_id: String,
	source: String,
	record_index: int,
	spell_id: int
) -> Dictionary:
	var result := {
		"authoredSpellId": spell_id,
		"spellId": spell_id,
		"corrected": false,
	}
	# Mithril Vault's random macro 4 selects either Finger of Death (3606)
	# or this row. The stored 1750 indexes beyond Classic's 15-spell row;
	# 1705 is the paired Sorcerer Heal Large Wounds spell.
	if (
		campaign_id == MITHRIL_VAULT_CAMPAIGN_ID
		and source == "Data ED3"
		and record_index == 6
		and spell_id == 1750
	):
		result["spellId"] = 1705
		result["corrected"] = true
		result["reason"] = "Mithril Vault spell 1750 is the transposed 1705 reference"
	return result
