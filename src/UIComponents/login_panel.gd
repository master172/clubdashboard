extends PanelContainer

@onready var user_id: LineEdit = $MarginContainer/VBoxContainer/Contents/MarginContainer/VBoxContainer/UserId/UserID
@onready var password_entry: LineEdit = $MarginContainer/VBoxContainer/Contents/MarginContainer/VBoxContainer/Password/PasswordEntry

signal login(userId:String,password:String)
@onready var invalid: Label = $MarginContainer/VBoxContainer/Invalid

var login_id:String = ""
var passcode:String = ""

func _ready() -> void:
	invalid.visible = false
	
func login_failed():
	user_id.text = ""
	password_entry.text = ""
	invalid.visible = true
	
func _on_user_id_text_changed(new_text: String) -> void:
	login_id = new_text


func _on_password_entry_text_changed(new_text: String) -> void:
	passcode = new_text


func _on_login_pressed() -> void:
	if Utils.is_whitespace(passcode):
		OS.alert("please enter proper password")
		return
	elif Utils.is_whitespace(login_id):
		OS.alert("please enter proper user id")
		return
	
	emit_signal("login",login_id,passcode)
