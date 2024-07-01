extends Node

@export var scale_spin: SpinBox
@export var outline_size_spin: SpinBox
@export var outline_color: ColorPickerButton
@export var export_style: OptionButton
@export var shadow_size_spin: SpinBox
@export var shadow_color: ColorPickerButton
@export var background_checkbutton: CheckButton
@export var background_color: ColorPickerButton

func _ready() -> void:
	scale_spin.value = GlobalSettings.export_scale
	outline_size_spin.value = GlobalSettings.export_outline_size
	outline_color.color = GlobalSettings.export_outline_color
	shadow_size_spin.value = GlobalSettings.export_shadow_size
	shadow_color.color = GlobalSettings.export_shadow_color
	background_checkbutton.button_pressed = GlobalSettings.export_background_enabled
	background_color.color = GlobalSettings.export_background_color

func _on_sprite_scale_value_changed(value: float) -> void:
	GlobalSettings.export_scale = int(value)

func _on_outline_size_value_changed(value: float) -> void:
	GlobalSettings.export_outline_size = int(value)

func _on_outline_color_changed(color: Color) -> void:
	GlobalSettings.export_outline_color = color

func _on_shadow_size_value_changed(value: float) -> void:
	GlobalSettings.export_shadow_size = int(value)

func _on_shadow_color_changed(color: Color) -> void:
	GlobalSettings.export_shadow_color = color

func _on_layout_style_selected(index: int) -> void:
	pass # Replace with function body.

func _on_background_toggled(toggled_on: bool) -> void:
	GlobalSettings.export_background_enabled = toggled_on

func _on_background_color_changed(color: Color) -> void:
	GlobalSettings.export_background_color = color
