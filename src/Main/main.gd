extends Control

var SlideActive:bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_profile_button_pressed() -> void:
	SlideActive = not SlideActive
	handle_sliding()

func handle_sliding():
	var anim_to_play = "SlideIn" if SlideActive else "SlideOut"
	animation_player.play(anim_to_play)


func _on_manage_events_pressed() -> void:
	var Manage_events_scene:PackedScene = load("res://src/Main/manage_events.tscn")
	get_tree().change_scene_to_packed(Manage_events_scene)


func _on_registrations_button_pressed() -> void:
	pass # Replace with function body.
