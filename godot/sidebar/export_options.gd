extends HFlowContainer

@export var scale_spin: SpinBox
@export var outline_spin: SpinBox
@export var color_selector: ColorPickerButton

func _ready() -> void:
	_on_scale_spin_value_changed(GlobalSettings.export_scale)
	_on_outline_spin_value_changed(GlobalSettings.export_outline_size)
	_on_outline_color_color_changed(GlobalSettings.export_outline_color)

func _on_scale_spin_value_changed(value: float) -> void:
	GlobalSettings.export_scale = int(value)

func _on_outline_spin_value_changed(value: float) -> void:
	GlobalSettings.export_outline_size = int(value)

func _on_outline_color_color_changed(color: Color) -> void:
	GlobalSettings.export_outline_color = color
