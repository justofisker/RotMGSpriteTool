extends Window

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		queue_free()

func _on_close_requested() -> void:
	queue_free()
