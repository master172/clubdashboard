extends Control

@onready var items: FlowContainer = $VBoxContainer/MarginContainer/ScrollContainer/Items

func _ready() -> void:
	pass
	
func _on_back_pressed() -> void:
	var Dashboard:PackedScene = load("res://src/Main/Main.tscn")
	get_tree().change_scene_to_packed(Dashboard)


func _on_registration_button_pressed() -> void:
	var RegistrationForm:PackedScene = load("res://src/Main/registrations.tscn")
	get_tree().change_scene_to_packed(RegistrationForm)


func _on_registration_1_pressed() -> void:
	_on_registration_button_pressed()
