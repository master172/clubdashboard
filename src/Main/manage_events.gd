extends Control


func _on_back_pressed() -> void:
	var Dashboard:PackedScene = load("res://src/Main/Main.tscn")
	get_tree().change_scene_to_packed(Dashboard)


func _on_create_new_button_pressed() -> void:
	pass # Replace with function body.
