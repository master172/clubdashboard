extends Control

@onready var items: FlowContainer = $VBoxContainer/MarginContainer/ScrollContainer/Items
const REGISTRATION_BUTTON_COMPONENT = preload("res://src/UIComponents/RegistrationButtonComponent.tscn")

func _ready() -> void:
	if Utils.login_club != "":
		attemt_events_creation()
	
func _on_back_pressed() -> void:
	var Dashboard:PackedScene = load("res://src/Main/Main.tscn")
	get_tree().change_scene_to_packed(Dashboard)


func _on_registration_button_pressed() -> void:
	var RegistrationForm:PackedScene = load("res://src/Main/registrations.tscn")
	get_tree().change_scene_to_packed(RegistrationForm)

func attemt_events_creation():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_request_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify({"club_name":Utils.login_club})
	var err = http.request(Utils.default_backend_url+"events",header,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if data != {}:
			add_event_buttons(data)
	else:
		push_error("request failed response code: ",response_code)

func add_event_buttons(button_entries:Dictionary)->void:
	for i in button_entries.keys():
		var button:Node =REGISTRATION_BUTTON_COMPONENT.instantiate()
		button.event_name = i
		button.pressed.connect(self.on_event_button_pressed.bind(button_entries[i]))
		button.Text = button_entries[i]
		items.add_child(button)

func on_event_button_pressed(event_id:String)->void:
	Utils.selected_event.enqueue(event_id)
	_on_registration_button_pressed()
