extends Control

var SlideActive:bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var login_container: Control = $LoginContainer

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
	var Manage_Registrations_scene:PackedScene = load("res://src/Main/manage_registrations.tscn")
	get_tree().change_scene_to_packed(Manage_Registrations_scene)


func _on_login_panel_login(userId: String, password: String) -> void:
	login_container.visible = false
	Utils.logged_in = true
	Utils.user_id = userId
	Utils.password = password


func _on_log_out_pressed() -> void:
	Utils.logged_in = false
	Utils.user_id = ""
	Utils.password = ""
	get_tree().reload_current_scene()
