extends Control

var SlideActive:bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var login_container: Control = $LoginContainer
@onready var profile_backdrop: PanelContainer = $Slide/MarginContainer/SlideOptions/ProfileBackdrop

var temp_user_id:String = ""
var temp_user_password:String = ""

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
	attemt_permission()
	
func change_scene_to_register()->void:
	var Manage_Registrations_scene:PackedScene = load("res://src/Main/manage_registrations.tscn")
	get_tree().change_scene_to_packed(Manage_Registrations_scene)


func _on_login_panel_login(userId: String, password: String) -> void:
	temp_user_id = userId
	temp_user_password = password
	
	attemt_login(userId,password)

func attemt_permission():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self.permission_granted)
	http.request_completed.connect(http.queue_free.unbind(4))
	var err = http.request(Utils.default_backend_url+"check_time")
	if err != OK:
		push_error("http request error: ",err)
	
func permission_granted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:bool = JSON.parse_string(body.get_string_from_utf8())
		if data == true:
			change_scene_to_register()
		else:
			OS.alert("You do not have permission to view registrations yet")
	else:
		push_error("request failed response code: ",response_code)
		
func attemt_login(user_id:String,password:String):
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_login_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify({"login_id":user_id,"password":password})
	var err = http.request(Utils.default_backend_url+"user",header,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:bool = JSON.parse_string(body.get_string_from_utf8())
		if data == true:
			login()
		else:
			login_container.login_failed()
	else:
		push_error("request failed response code: ",response_code)

func attemt_club_name(user_id:String):
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_club_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify({"user_id":user_id})
	var err = http.request(Utils.default_backend_url+"club",header,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_club_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:String = JSON.parse_string(body.get_string_from_utf8())
		Utils.login_club = data
		profile_backdrop._set_data()
		login_container.visible = false
		Utils.logged_in = true
		Utils.save_info()
	else:
		push_error("request failed response code: ",response_code)
		
func login():
	Utils.user_id = temp_user_id
	Utils.password = temp_user_password
	attemt_club_name(temp_user_id)
	temp_user_id = ""
	temp_user_password = ""
	
	
func _on_log_out_pressed() -> void:
	Utils.logged_in = false
	Utils.user_id = ""
	Utils.password = ""
	Utils.login_club = ""
	get_tree().reload_current_scene()
	Utils.save_info()


func _on_winner_button_pressed() -> void:
	var Go_To_Winners :PackedScene = load("res://src/Main/go_to_winners.tscn")
	get_tree().change_scene_to_packed(Go_To_Winners)
