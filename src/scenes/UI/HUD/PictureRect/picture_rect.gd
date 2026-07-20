extends ColorRect

@onready var pictxtrect : TextureRect = $TextureRect

func display_image(img_name: String) -> bool:
	var path: String = (
		Paths.campaignsfolderpath
		+ GameGlobal.currentcampaign
		+ "/Splash Images/"
		+ img_name
	)
	return display_image_path(path)


func display_image_path(path: String) -> bool:
	var maptexture: ImageTexture = Utils.FileHandler.load_img_texture(path)
	if maptexture.get_width() <= 0 or maptexture.get_height() <= 0:
		return false
	pictxtrect.texture = maptexture
	show()
	return true
