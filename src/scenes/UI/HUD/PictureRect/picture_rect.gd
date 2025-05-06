extends ColorRect

@onready var pictxtrect : TextureRect = $TextureRect

func display_image(img_name : String) :
	var path : String = Paths.campaignsfolderpath + GameGlobal.currentcampaign + "/Splash Images/" + img_name
	var maptexture : ImageTexture = Utils.FileHandler.load_img_texture(path)
	pictxtrect.texture = maptexture
	show()
	
