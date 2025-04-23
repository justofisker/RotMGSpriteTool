extends Button

@onready var bg_hover: NinePatchRect = $BGHover

var tween: Tween = null
var tween_exit: Tween = null

func _on_mouse_entered() -> void:
	bg_hover.size.x = 0
	bg_hover.position.x = (size.x - bg_hover.size.x) / 2.0
	bg_hover.visible = true
	bg_hover.self_modulate = Color.WHITE
	if tween != null:
		tween.kill()
	if tween_exit != null:
		tween_exit.kill()
		tween_exit = null
	tween = create_tween()
	tween.tween_property(bg_hover, "position", Vector2.ZERO, .1)
	tween.parallel().tween_property(bg_hover, "size", Vector2(size.x, size.y), .1)
	tween.tween_callback(self.set.bind("tween", null))

func _on_mouse_exited() -> void:
	if tween_exit != null:
		tween_exit.kill()
	tween_exit = create_tween()
	tween_exit.tween_property(bg_hover, "self_modulate", Color(Color.WHITE, 0.0), .1)
	tween_exit.tween_callback(bg_hover.set.bind("visible", false))
	tween_exit.tween_callback(self.set.bind("tween_exit", null))
