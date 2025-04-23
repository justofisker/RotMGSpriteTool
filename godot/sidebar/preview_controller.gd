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
	%Preview.get_parent()._reposition_hflip()

func _on_right_pressed() -> void:
	%Preview.direction = 0
	%Preview.flip_h = false
	%Preview.get_parent()._reposition_hflip()

func _on_down_pressed() -> void:
	%Preview.direction = 3
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

func _on_preview_animation_changed() -> void:
	var disable = func(btn: TextureButton) -> void:
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)
	var enable = func(btn: TextureButton) -> void:
		btn.disabled = false
		btn.modulate = Color.WHITE
	
	if %Preview.sprite_frames.has_animation("A%dD0" % type):
		enable.call(left)
		enable.call(right)
	else:
		disable.call(left)
		disable.call(right)
	if %Preview.sprite_frames.has_animation("A%dD2" % type):
		enable.call(up)
	else:
		disable.call(up)
	if %Preview.sprite_frames.has_animation("A%dD3" % type):
		enable.call(down)
	else:
		disable.call(down)

func _on_preview_sprite_frames_changed() -> void:
	self.type = AnimationType.Idle
	%Preview.flip_h = false
	_on_preview_animation_changed()
	# TODO: Disable action animation if not present
