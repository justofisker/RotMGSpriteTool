class_name ExportData extends Resource

enum ExportMode {
	MULTITEXTURES,
	MULTITEXTURES_TIMED,
	SINGLE_TEXTURE,
	ANIMATED_TEXTURE,
	NONE = -1,
}

var export_mode : ExportMode = ExportMode.NONE
var textures: Array[RotmgTexture] = []
var durations: PackedFloat32Array = []
var texture: RotmgTexture = null
var animated_textures: Array[RotmgAnimatedTexture] = []

static func from_texture_array(t: Array[RotmgTexture]) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.MULTITEXTURES
	data.textures = t
	data.durations = []
	data.texture = null
	data.animated_textures = []
	return data

static func from_texture_time_array(t: Array[RotmgTexture], d: PackedFloat32Array) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.MULTITEXTURES_TIMED
	data.textures = t
	data.durations = d
	data.texture = null
	data.animated_textures = []
	return data

static func from_texture(t: RotmgTexture) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.SINGLE_TEXTURE
	data.textures = []
	data.durations = []
	data.texture = t
	data.animated_textures = []
	return data

static func from_animated_textures(at: Array[RotmgAnimatedTexture]) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.ANIMATED_TEXTURE
	data.textures = []
	data.durations = []
	data.texture = null
	data.animated_textures = at
	return data

func create_window() -> Window:
	var window = preload("res://export_window/export_window.tscn").instantiate()
	window.get_child(0).export_data = self
	return window
