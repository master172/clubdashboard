extends Control

@onready var login_panel: PanelContainer = $CenterContainer/LoginPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await Utils.ready
	visible = not Utils.logged_in


func login_failed():
	login_panel.login_failed()
