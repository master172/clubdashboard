extends Control

func _on_back_pressed() -> void:
	var registration_manager = load("res://src/Main/manage_registrations.tscn")
	get_tree().change_scene_to_packed(registration_manager)
