extends Button

func _on_pressed() -> void:
	add_child(preload("res://about/about.tscn").instantiate())
