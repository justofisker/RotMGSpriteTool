extends PanelContainer

@export var character_id: Label

@export var animations: Control
@export var alt_textures: Control
@export var sprite_view: Control

var character: Character :
	set(value):
		character = value
		character_id.text = character.id
		animations.character = character
		alt_textures.character = character
		sprite_view.character = character
