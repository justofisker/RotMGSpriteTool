extends Node

var export_scale: int = 5 :
	set(value):
		export_scale = value
		export_setting_changed.emit()
var export_outline_size: int = 1 :
	set(value):
		export_outline_size = value
		export_setting_changed.emit()
var export_outline_color: Color = Color.BLACK :
	set(value):
		export_outline_color = value
		export_setting_changed.emit()

signal export_setting_changed
