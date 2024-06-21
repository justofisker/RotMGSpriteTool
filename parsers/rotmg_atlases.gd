extends Node

var map_objects_texture: Texture2D
var ground_tiles_texture: Texture2D
var characters_texture: Texture2D

var sprite_sheets: Dictionary
var animation_sheets: Dictionary

func _ready() -> void:
	parse_atlases()

func parse_atlases() -> void:
	if true:
		map_objects_texture = preload("res://assets/atlases/mapObjects.png")
		ground_tiles_texture = preload("res://assets/atlases/groundTiles.png")
		characters_texture = preload("res://assets/atlases/characters.png")
	else:
		const MAP_OBJECTS_PATH := "res://assets/atlases/mapObjects.png"
		if FileAccess.file_exists(MAP_OBJECTS_PATH):
			var img := Image.new()
			img.load(MAP_OBJECTS_PATH)
			map_objects_texture = ImageTexture.create_from_image(img)
		const GROUND_TILES_PATH := "res://assets/atlases/groundTiles.png"
		if FileAccess.file_exists(GROUND_TILES_PATH):
			var img := Image.new()
			img.load(GROUND_TILES_PATH)
			ground_tiles_texture = ImageTexture.create_from_image(img)
		const CHARACTERS_PATH := "res://assets/atlases/characters.png"
		if FileAccess.file_exists(CHARACTERS_PATH):
			var img := Image.new()
			img.load(CHARACTERS_PATH)
			characters_texture = ImageTexture.create_from_image(img)
	
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string("res://assets/atlases/spritesheet.json")) != OK:
		print("Error whilst parsing spritesheets.json: ", json.get_error_message(), " on line ", json.get_error_line(), ".")
		return
	
	var data : Dictionary = json.data
	
	for atlas in data["sprites"]:
		var sprite_sheet_name: String = atlas["spriteSheetName"]
		
		if atlas.has("elements"): # Static sprites
			var regions : Array[Rect2] = []
			var indices : Array[int] = []
			var atlas_id : int = int(atlas["atlasId"])
			for element in atlas["elements"]:
				var position = element["position"]
				var idx := indices.bsearch(int(element["index"]))
				regions.insert(idx, Rect2(position["x"], position["y"], position["w"], position["h"]))
				indices.insert(idx, int(element["index"]))
		
			var sprite_sheet = SpriteSheet.new()
			sprite_sheet.regions = regions
			sprite_sheet.indices = indices
			sprite_sheet.atlas_id = atlas_id
			sprite_sheets[sprite_sheet_name] = sprite_sheet
	
	for frame in data["animatedSprites"]:
		var sprite_sheet_name: String = frame["spriteSheetName"]
		if !animation_sheets.has(sprite_sheet_name):
			animation_sheets[sprite_sheet_name] = AnimationSheet.new()
		
		var sheet : AnimationSheet = animation_sheets[sprite_sheet_name]
		
		var f := AnimationFrame.new()
		f.direction = frame["direction"]
		f.action = frame["action"]
		f.frame_set = frame["set"]
		f.atlas_id = frame["spriteData"]["aId"]
		f.region.position.x = frame["spriteData"]["position"]["x"]
		f.region.position.y = frame["spriteData"]["position"]["y"]
		f.region.size.x = frame["spriteData"]["position"]["w"]
		f.region.size.y = frame["spriteData"]["position"]["h"]
		
		var frame_index := int(frame["index"])
		var position := sheet.indices.bsearch(frame_index)
		
		if sheet.indices.has(frame_index):
			var animation : RotmgAnimation = sheet.animations[position]
			animation.frames.append(f)
		else:
			var animation := RotmgAnimation.new()
			animation.frames.append(f)
			sheet.animations.insert(position, animation)
			sheet.indices.insert(position, frame_index)
			
	
class SpriteSheet:
	var regions: Array[Rect2]
	var indices: Array[int]
	var atlas_id: int

class AnimationSheet:
	var animations: Array[RotmgAnimation]
	var indices: Array[int]
	
class RotmgAnimation:
	var frames: Array[AnimationFrame]

class AnimationFrame:
	var atlas_id: int
	var direction: int
	var action: int
	var frame_set: int
	var region: Rect2

func _get_atlas_texture(atlas_id: int, region: Rect2) -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.region = region
	match atlas_id:
		1:
			atlas_texture.atlas = ground_tiles_texture
		2:
			atlas_texture.atlas = characters_texture
		4:
			atlas_texture.atlas = map_objects_texture
		_:
			push_error("Unknown atlas_id of ", atlas_id, ".")
			return null
	return atlas_texture

func get_animated_sprite(sheet_name: String, index: int) -> AnimatedSprite2D:
	var anim_sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	anim_sprite.sprite_frames = frames
	
	if animation_sheets.has(sheet_name):
		var animation_sheet : AnimationSheet = animation_sheets[sheet_name]
		
		if animation_sheet.indices.has(index):
			var idx = animation_sheet.indices.bsearch(index)
			var animation := animation_sheet.animations[idx]
			for f in animation.frames:
				frames.add_frame("default", _get_atlas_texture(f.atlas_id, f.region))
	
	return anim_sprite

func get_texture(sheet_name: String, index: int) -> AtlasTexture:
	if sprite_sheets.has(sheet_name):
		var sprite_sheet : SpriteSheet = sprite_sheets[sheet_name]
		if sprite_sheet.indices.has(index):
			return _get_atlas_texture(sprite_sheet.atlas_id, sprite_sheet.regions[sprite_sheet.indices.bsearch(index)])
		else:
			push_error("Sprite with index of ", index, " in sheet ", sheet_name, " does not exist.")
	else:
		push_error("Cannot find sprite sheet with name ", sheet_name, ".")
	return null
	
