extends Control

@onready var type_switch: TextureButton = $TypeSwitch

enum AnimationType {
	Idle,
	Walk,
	Attack,
	Max,
}

var type := AnimationType.Idle :
	set(new_type):
		type = new_type
		match type:
			AnimationType.Idle:
				type_switch.texture_normal = preload("res://sidebar/Idle.png")
			AnimationType.Walk:
				type_switch.texture_normal = preload("res://sidebar/Walk.png")
			AnimationType.Attack:
				type_switch.texture_normal = preload("res://sidebar/Attack.png")

func _on_type_switch_pressed() -> void:
	self.type = (type + 1) % AnimationType.Max
	%Preview.action = type

func _on_up_pressed() -> void:
	%Preview.direction = 2
	%Preview.flip_h = false

func _on_left_pressed() -> void:
	%Preview.direction = 0
	%Preview.flip_h = true

func _on_right_pressed() -> void:
	%Preview.direction = 0
	%Preview.flip_h = false

func _on_down_pressed() -> void:
	%Preview.direction = 1
	%Preview.flip_h = false

@onready var container: Control = $"."

const TIME : float = 0.2
var tween: Tween = null
func _on_preview_window_mouse_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(container, "modulate", Color(1, 1, 1, 1), TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(set.bind("tween", null))

func _on_preview_window_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(container, "modulate", Color(1, 1, 1, 0), TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(set.bind("tween", null))

@onready var up: TextureButton = $Up
@onready var left: TextureButton = $Left
@onready var right: TextureButton = $Right
@onready var down: TextureButton = $Down
func _on_preview_avaliable_directions(directions: Array[int]) -> void:
	if directions.find(0) != -1:
		left.disabled = false
		left.modulate = Color.WHITE
		right.disabled = false
		right.modulate = Color.WHITE
	else:
		left.disabled = true
		left.modulate = Color(1, 1, 1, 0.5)
		right.disabled = true
		right.modulate = Color(1, 1, 1, 0.5)
	if directions.find(1) != -1:
		up.disabled = false
		up.modulate = Color.WHITE
	else:
		up.disabled = true
		up.modulate = Color(1, 1, 1, 0.5)
	if directions.find(2) != -1:
		down.disabled = false
		down.modulate = Color.WHITE
	else:
		down.disabled = true
		down.modulate = Color(1, 1, 1, 0.5)
