extends Control

@onready var contact_no: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/ContactNo/MarginContainer/HBoxContainer/contact_no
@onready var event_name: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/EventName/MarginContainer/HBoxContainer/event_name
@onready var description: TextEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/EventDescription/MarginContainer/HBoxContainer/description
@onready var num_teams: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/NumTeams/MarginContainer/HBoxContainer/num_teams
@onready var num_participants: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/NumParticipants/MarginContainer/HBoxContainer/num_participants
@onready var timings: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/Timings/MarginContainer/HBoxContainer/timings
@onready var fees: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/Fees/MarginContainer/HBoxContainer/fees
@onready var rule_container: VBoxContainer = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/RulesPanel/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/RuleContainer

const RULE = preload("res://src/UIComponents/rule.tscn")

@onready var fields :Array[Node]= [
	event_name,
	description,
	num_teams,
	num_participants,
	timings,
	fees,
	contact_no,
]

@onready var field_map:Dictionary[Node,String] = {
	event_name:"event_name",
	description:"description",
	num_teams:"num_teams",
	num_participants:"num_participants",
	timings:"timings",
	fees:"fees",
	contact_no:"contact_no",
}

var data:Dictionary = {
	"club_name":Utils.login_club,
	"event_id":"",
	"event_name":"",
	"description":"",
	"rules":[],
	"num_participants":0,
	"num_teams":0,
	"timings":"",
	"contact_no":"",
	"fees":0
}

func _ready() -> void:
	if Utils.selected_event.size() != 0:
		
		attemt_event_load()
	else:
		attemt_events_size()

func _on_back_pressed() -> void:
	var EventManager:PackedScene = load("res://src/Main/manage_events.tscn")
	get_tree().change_scene_to_packed(EventManager)


func _on_contact_no_text_submitted(new_text: String) -> void:
	var valid_phone_number:bool = Utils.is_valid_phone_number(new_text)
	if not valid_phone_number:
		OS.alert("Please enter valid phone number")
		contact_no.text = ""
		contact_no.release_focus()
	else:
		data["contact_no"] = new_text
		contact_no.release_focus()


func _on_event_name_text_submitted(new_text: String) -> void:
	if Utils.is_whitespace(new_text):
		OS.alert("please enter valid event name")
		event_name.text = ""
		event_name.release_focus()
		return
	data["event_name"] = new_text
	event_name.release_focus()


func _on_description_text_set() -> void:
	if Utils.is_whitespace(description.text):
		OS.alert("please enter valid Description")
		description.text = ""
		description.release_focus()
		return
	data["description"] = description.text
	description.release_focus()

func _on_add_rule_pressed() -> void:
	var new_rule:Node = RULE.instantiate()
	new_rule.name = "rule_"+str(rule_container.get_child_count())
	new_rule.rule_entered.connect(self.add_rule)
	rule_container.add_child(new_rule)
	fields.append(new_rule)
	
func add_rule(string:String):
	data["rules"].append(string)

func _on_num_teams_value_changed(value: float) -> void:
	data["num_teams"] = int(value)


func _on_num_participants_value_changed(value: float) -> void:
	data["num_participants"] = int(value)

func _on_timings_text_submitted(new_text: String) -> void:
	if Utils.is_whitespace(new_text):
		OS.alert("please enter valid Timings")
		timings.text = ""
		timings.release_focus()
		return
	data["timings"] = new_text
	timings.release_focus()


func _on_fees_value_changed(value: float) -> void:
	data["fees"] = int(value)


func _on_save_pressed() -> void:
	data["rules"] = []
	for i:Node in fields:
		if i.name.begins_with("rule_"):
			data["rules"].append(i.text)
		else:
			data[field_map[i]] = i.text if Utils.has_property(i,"text") else int(i.value)
	
	if Utils.login_club == "":
		_on_back_pressed()
	else:
		attemt_event_creation(data)

func attemt_event_creation(Data:Dictionary):
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_event_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify(Data)
	var err = http.request("http://127.0.0.1:8000/create_event",header,HTTPClient.METHOD_POST,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_event_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		_on_back_pressed()
	else:
		push_error("request failed response code: ",response_code)

func attemt_event_load():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_load_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var loading_event = Utils.selected_event.get_front()
	data["event_id"] = loading_event
	var body:String = JSON.stringify({"club_name":Utils.login_club,"event_name":loading_event})
	
	var err = http.request("http://127.0.0.1:8000/event",header,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_load_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var Data:Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if Data != {}:
			load_event_details(Data)
	else:
		push_error("request failed response code: ",response_code)

func load_event_details(Data:Dictionary):
	
	event_name.text = Data.event_name
	description.text = Data.description
	timings.text = Data.timings
	contact_no.text = Data.contact_no
	num_teams.set_value(Data.num_teams)
	num_participants.set_value(Data.num_participants)
	fees.set_value(Data.fees)

	for i in Data.rules:
		var new_rule:Node = RULE.instantiate()
		new_rule.name = "rule_"+str(rule_container.get_child_count())
		new_rule.rule_entered.connect(self.add_rule)
		rule_container.add_child(new_rule)
		new_rule.text = i
		fields.append(new_rule)
	
func attemt_events_size():
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_size_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify({"club_name":Utils.login_club})
	
	var err = http.request("http://127.0.0.1:8000/event_size",header,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error("http request error: ",err)
	
func _on_size_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var Data_number :int = JSON.parse_string(body.get_string_from_utf8())
		if Data_number != null:
			data["event_id"] = "event_"+str(Data_number+1)
	else:
		push_error("request failed response code: ",response_code)
