class_name RuntimeFixtureExtensionProvider
extends ScenarioExtensionProvider

var marker := ""


func provider_id() -> String:
	return "scenario.runtime-fixture.providers"


func api_version() -> int:
	return 1


func binding_ids() -> Dictionary:
	return {
		"spells": ["scenario.runtime-fixture.echo-spell"],
		"itemBehaviors": ["scenario.runtime-fixture.echo-item"],
		"encounterResolvers": ["scenario.runtime-fixture.echo-encounter"],
		"monsterAiProviders": ["scenario.runtime-fixture.echo-ai"],
		"lifecycleHooks": ["scenario.runtime-fixture.lifecycle"],
	}


func configure(configuration: Dictionary) -> Dictionary:
	marker = str(configuration.get("marker", ""))
	return {"status": "ok"}


func invoke(
	capability: String,
	binding_id: String,
	payload: Dictionary,
	_context: Object
) -> Dictionary:
	return {
		"status": "ok",
		"providerId": provider_id(),
		"capability": capability,
		"bindingId": binding_id,
		"marker": marker,
		"payload": payload.duplicate(true),
	}
