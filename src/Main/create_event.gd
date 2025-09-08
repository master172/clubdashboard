extends Control

@onready var contact_no: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/ContactNo/MarginContainer/HBoxContainer/contact_no
@onready var event_name: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/EventName/MarginContainer/HBoxContainer/event_name
@onready var description: TextEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/EventDescription/MarginContainer/HBoxContainer/description
@onready var num_teams: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/NumTeams/MarginContainer/HBoxContainer/num_teams
@onready var num_participants: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/NumParticipants/MarginContainer/HBoxContainer/num_participants
@onready var timings: LineEdit = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/Timings/MarginContainer/HBoxContainer/timings
@onready var fees: SpinBox = $VBoxContainer/MarginContainer/ScrollContainer/FormContainer/NumParticipants2/MarginContainer/HBoxContainer/fees
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
	"event_name":"",
	"description":"",
	"rules":[],
	"num_participants":0,
	"num_teams":0,
	"timings":"",
	"contact_no":"",
	"fees":0
}
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
	
	_on_back_pressed()
