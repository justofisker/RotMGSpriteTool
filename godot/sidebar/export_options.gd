extends HFlowContainer

@onready var export_scale: int = scale_spin.value
@onready var outline_size: int = outline_spin.value
@onready var outline_color: Color = color_selector.color

@export var scale_spin: SpinBox
@export var outline_spin: SpinBox
@export var color_selector: ColorPickerButton
@export var sprite : AnimatedSprite2D

func _ready() -> void:
	_on_scale_spin_value_changed(export_scale)
	_on_outline_spin_value_changed(outline_size)
	_on_outline_color_color_changed(outline_color)

func _on_scale_spin_value_changed(value: float) -> void:
	export_scale = int(value)
	sprite.scale = Vector2(export_scale, export_scale)
	sprite.get_parent()._resize_to_animation()
	sprite.get_parent()._reposition_frame()
	(sprite.material as ShaderMaterial).set_shader_parameter("scale", export_scale)
	
func _on_outline_spin_value_changed(value: float) -> void:
	outline_size = int(value)
	(sprite.material as ShaderMaterial).set_shader_parameter("outline_size", outline_size)

func _on_outline_color_color_changed(color: Color) -> void:
	outline_color = color
	(sprite.material as ShaderMaterial).set_shader_parameter("outline_color", outline_color)
