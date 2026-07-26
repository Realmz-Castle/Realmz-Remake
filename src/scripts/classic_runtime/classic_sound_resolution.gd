extends RefCounted

const SUPPORTED_RUNTIME_MEDIA_TYPES := [
	"audio/wav",
	"audio/x-wav",
	"audio/wave",
	"audio/ogg",
	"audio/vorbis",
	"audio/mpeg",
	"audio/mp3",
]


static func resolve(
	sound_id: int,
	sound: Dictionary,
	native_mapping: Dictionary
) -> Dictionary:
	var resource_id := absi(sound_id)
	var resolution := {
		"signedResourceId": sound_id,
		"resourceId": resource_id,
		"playable": false,
		"waitForCompletion": false,
	}
	if sound_id == 0:
		resolution.merge({
			"status": "silent-sentinel",
			"sourceBehavior": "silent-noop",
		})
		return resolution

	var runtime_media: Variant = sound.get("runtimeMedia", {})
	if runtime_media is Dictionary and not runtime_media.is_empty():
		var media_type := str(runtime_media.get("mediaType", "")).to_lower()
		resolution["runtimeMediaPath"] = str(runtime_media.get("path", ""))
		resolution["runtimeMediaType"] = media_type
		if media_type not in SUPPORTED_RUNTIME_MEDIA_TYPES:
			resolution["status"] = "unsupported-runtime-media"
			return resolution
		resolution["status"] = "runtime-media"
		resolution["playable"] = true
		resolution["waitForCompletion"] = sound_id < 0
		return resolution

	if not sound.is_empty():
		resolution["status"] = "missing-runtime-media"
		return resolution

	var native_name := str(native_mapping.get(
		resource_id,
		native_mapping.get(str(resource_id), "")
	)).strip_edges()
	if not native_name.is_empty():
		resolution["status"] = "native-mapping"
		resolution["nativeName"] = native_name
		resolution["playable"] = true
		resolution["waitForCompletion"] = sound_id < 0
		return resolution

	resolution.merge({
		"status": "unresolved-external-classic-resource",
		"remakeBehavior": "no-playback",
		"classicBehaviorIfAbsent": "silent-noop",
	})
	return resolution
