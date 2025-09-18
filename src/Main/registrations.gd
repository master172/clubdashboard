extends Control

var selected_event:String = ""
const INDUVIDUALDELEGATE = preload("res://src/UIComponents/Induvidualdelegate.tscn")
const INSTITUTION_DELEGATE = preload("res://src/UIComponents/InstitutionDelegate.tscn")

@onready var induviduals: VBoxContainer = $VBoxContainer/MarginContainer/TabContainer/Induvidual/FormContainer/Induviduals
@onready var institutions: VBoxContainer = $VBoxContainer/MarginContainer/TabContainer/Institution/FormContainer/Institutions

func _ready() -> void:
	if Utils.selected_event.size() != 0:
		selected_event = Utils.selected_event.get_front()
		get_individual_registrations()
		get_institution_registrations()
	
func _on_back_pressed() -> void:
	var registration_manager = load("res://src/Main/manage_registrations.tscn")
	get_tree().change_scene_to_packed(registration_manager)

func get_individual_registrations():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self.induvidual_request_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var club = Utils.login_club.uri_encode()
	var event = selected_event.uri_encode()
	var url:String = Utils.default_backend_url+"registrations/individual/"+club+"/"+event
	var err = http.request(url)
	if err != OK:
		push_error("http request error: ",err)
	
func induvidual_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:Dictionary = JSON.parse_string(body.get_string_from_utf8())
		add_individual_registration(data)
	else:
		if response_code == 404:
			OS.alert("No individual registrations found")
		else:
			push_error("request failed response code: ",response_code)

func get_institution_registrations():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self.institution_request_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var club = Utils.login_club.uri_encode()
	var event = selected_event.uri_encode()
	var url:String = Utils.default_backend_url+"registrations/institution/"+club+"/"+event
	var err = http.request(url)
	if err != OK:
		push_error("http request error: ",err)
	
func institution_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:Dictionary = JSON.parse_string(body.get_string_from_utf8())
		add_institution_registrations(data)
	else:
		if response_code == 404:
			OS.alert("No institution registrations found")
		else:
			push_error("request failed response code: ",response_code)

func add_individual_registration(data:Dictionary)->void:
	for i in data["registrations"]:
		var delegate:Node = INDUVIDUALDELEGATE.instantiate()
		induviduals.add_child(delegate)
		delegate._load_data(i)

func add_institution_registrations(data:Dictionary)->void:
	for i in data["registrations"]:
		var delegate:Node = INSTITUTION_DELEGATE.instantiate()
		institutions.add_child(delegate)
		delegate._load_data(i)
