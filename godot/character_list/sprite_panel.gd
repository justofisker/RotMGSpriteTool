extends PanelContainer

@export var label: Label
@export var vbox: VBoxContainer
@export var sprite: TextureRect
@onready var background_selected: NinePatchRect = $BackgroundSelected

var character: Character :
	set(value):
		character = value
		label.text = character.id
		_setup_sprite()

func _setup_sprite() -> void:
	if !is_instance_valid(character.texture):
		return
	
	if character.texture.animated:
		for animated_sprite in character.texture.animated_sprites:
			if animated_sprite.action == 0 && animated_sprite.direction == 0:
				sprite.texture = RotmgAtlases.get_animated_texture(animated_sprite)
		if !sprite.texture:
			sprite.texture = RotmgAtlases.get_animated_texture(character.texture.animated_sprites[0])
	else:
		sprite.texture = RotmgAtlases.get_texture(character.texture.sprite)
	
	if sprite.texture:
		sprite.texture.region.position -= Vector2(1, 1)
		sprite.texture.region.size += Vector2(2, 2)
		sprite.custom_minimum_size = sprite.texture.get_size() * 5

func _on_button_pressed() -> void:
	return
	get_tree().get_first_node_in_group("sidebar").character = character

func _on_button_focus_entered() -> void:
	background_selected.visible = true

func _on_button_focus_exited() -> void:
	background_selected.visible = false
