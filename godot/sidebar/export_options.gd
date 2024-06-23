extends HFlowContainer

@export var scale_spin: SpinBox
@export var outline_spin: SpinBox
@export var color_selector: ColorPickerButton

func _ready() -> void:
	scale_spin.value = GlobalSettings.export_scale
	outline_spin.value = GlobalSettings.export_outline_size
	color_selector.color = GlobalSettings.export_outline_color

func _on_scale_spin_value_changed(value: float) -> void:
	GlobalSettings.export_scale = int(value)

func _on_outline_spin_value_changed(value: float) -> void:
	GlobalSettings.export_outline_size = int(value)

func _on_outline_color_color_changed(color: Color) -> void:
	GlobalSettings.export_outline_color = color
