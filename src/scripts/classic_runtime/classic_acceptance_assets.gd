class_name ClassicAcceptanceAssets
extends RefCounted

const PLAYER_ICON_PATH := "res://Data/Character Icons/Human 1.png"
const CLASSIC_PORTRAIT_257_PATH := \
	"res://Data/Character Portraits/Human 1.png"
const ELF_ICON_PATH := "res://Data/Character Icons/Elf 1.png"
const ELF_PORTRAIT_PATH := "res://Data/Character Portraits/Elf 1.png"


static func player_icon() -> ImageTexture:
	return _load_data_texture(PLAYER_ICON_PATH)


static func classic_portrait_257() -> ImageTexture:
	return _load_data_texture(CLASSIC_PORTRAIT_257_PATH)


static func elf_player_icon() -> ImageTexture:
	return _load_data_texture(ELF_ICON_PATH)


static func elf_player_portrait() -> ImageTexture:
	return _load_data_texture(ELF_PORTRAIT_PATH)


static func _load_data_texture(resource_path: String) -> ImageTexture:
	var image := Image.load_from_file(ProjectSettings.globalize_path(resource_path))
	if image == null or image.is_empty():
		push_error("Classic acceptance artwork is unavailable: %s" % resource_path)
		return null
	return ImageTexture.create_from_image(image)
