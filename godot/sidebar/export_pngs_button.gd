extends Button

var export_data: ExportData = null

func _on_pressed():
	if is_instance_valid(export_data):
		var window = export_data.create_window()
		add_child(window)
		window.show()
	else:
		push_error("No export data")
