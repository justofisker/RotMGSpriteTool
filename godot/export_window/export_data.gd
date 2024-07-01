class_name ExportData extends Resource

enum ExportMode {
	MULTITEXTURES,
	MULTITEXTURES_TIMED,
	SINGLE_TEXTURE,
	ANIMATED_TEXTURE,
	NONE = -1,
}

var export_mode : ExportMode = -1
var textures: Array[RotmgTexture] = []
var durations: PackedFloat32Array = []
var texture: RotmgTexture = null
var animated_textures: Array[RotmgAnimatedTexture] = []

static func from_texture_array(textures: Array[RotmgTexture]) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.MULTITEXTURES
	data.textures = textures
	data.durations = []
	data.texture = null
	data.animated_textures = []
	return data

static func from_texture_time_array(textures: Array[RotmgTexture], durations: PackedFloat32Array) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.MULTITEXTURES_TIMED
	data.textures = textures
	data.durations = durations
	data.texture = null
	data.animated_textures = []
	return data

static func from_texture(texture: RotmgTexture) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.SINGLE_TEXTURE
	data.textures = []
	data.durations = []
	data.texture = texture
	data.animated_textures = []
	return data

static func from_animated_textures(animated_textures: Array[RotmgAnimatedTexture]) -> ExportData:
	var data := ExportData.new()
	data.export_mode = ExportMode.ANIMATED_TEXTURE
	data.textures = []
	data.durations = []
	data.texture = null
	data.animated_textures = animated_textures
	return data

func create_window() -> Window:
	var window = preload("res://export_window/export_window.tscn").instantiate()
	window.get_child(0).export_data = self
	return window
