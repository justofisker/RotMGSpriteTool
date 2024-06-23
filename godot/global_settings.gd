extends Node

var export_scale: int = 5 :
	set(value):
		export_scale = value
		export_setting_changed.emit()
		setting_changed.emit()
var export_outline_size: int = 1 :
	set(value):
		export_outline_size = value
		export_setting_changed.emit()
		setting_changed.emit()
var export_outline_color: Color = Color.BLACK :
	set(value):
		export_outline_color = value
		export_setting_changed.emit()
		setting_changed.emit()

var last_save_location : String = "./" :
	set(value):
		last_save_location = value
		setting_changed.emit()

signal export_setting_changed
signal setting_changed

func _ready() -> void:
	load_settings()	
	setting_changed.connect(save_settings)

const SETTINGS_FILE := "settings.json"

func load_settings() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE):
		return
	
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	var json_string := file.get_as_text()
	file.close()
	var json := JSON.new()
	json.parse(json_string)
	
	var data : Dictionary = json.data
	
	export_scale = data.get("exprot_scale", export_scale)
	export_outline_size = data.get("export_outline_size", export_outline_size)
	export_outline_color = Color.from_string(data.get("export_outline_color", export_outline_color.to_html(false)), export_outline_color)
	last_save_location = data.get("last_save_location", last_save_location)

func save_settings() -> void:
	var settings = {
		"export_scale": export_scale,
		"export_outline_size": export_outline_size,
		"export_outline_color": export_outline_color.to_html(false),
		"last_save_location": last_save_location,
	}
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(settings, "\t"))
	file.close()
