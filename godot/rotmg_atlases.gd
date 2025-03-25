extends Node

@onready var spritesheetf := SpriteSheetDeserializer.open("res://assets/atlases/spritesheetf")
@onready var atlases : Array[Texture2D]

func _ready() -> void:
	if OS.has_feature("editor"):
		atlases = [
			null,
			load("res://assets/atlases/groundTiles.png"),
			load("res://assets/atlases/characters.png"),
			load("res://assets/atlases/characters_masks.png"),
			load("res://assets/atlases/mapObjects.png")
		]
	else:
		atlases = [
			null,
			ImageTexture.create_from_image(Image.load_from_file("res://assets/atlases/groundTiles.png")),
			ImageTexture.create_from_image(Image.load_from_file("res://assets/atlases/characters.png")),
			ImageTexture.create_from_image(Image.load_from_file("res://assets/atlases/characters_masks.png")),
			ImageTexture.create_from_image(Image.load_from_file("res://assets/atlases/mapObjects.png")),
		]

func get_sprite(sprite_sheet_name: String, index: int) -> RotmgSprite:
	for sprite_sheet in spritesheetf.sprite_sheets:
		if sprite_sheet.sprite_sheet_name == sprite_sheet_name:
			for sprite in sprite_sheet.sprites:
				if sprite.index == index:
					return sprite
	push_warning("Failed to find sprite for " + sprite_sheet_name + ":" + str(index))
	return null

func get_animated_sprites(sprite_sheet_name: String, index: int) -> Array[RotmgAnimatedSprite]:
	var out : Array[RotmgAnimatedSprite]
	for sprite in spritesheetf.animated_sprites:
		if sprite.sprite_sheet_name == sprite_sheet_name && sprite.index == index:
			out.push_back(sprite)
	return out

func get_texture(sprite: RotmgSprite) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = atlases[sprite.a_id]
	texture.region = sprite.position
	return texture

func get_animated_texture(animated_sprite: RotmgAnimatedSprite) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = atlases[animated_sprite.sprite.a_id]
	texture.region = animated_sprite.sprite.position
	return texture
