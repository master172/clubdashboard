extends Control

var selected_event:String = ""
var event_id:String = ""

var INDIVIDUAL_REGISTRATIONS:Dictionary = {}
var INSTITUTION_REGISTRATIONS:Dictionary = {}

const INDUVIDUALDELEGATE = preload("res://src/UIComponents/Induvidualdelegate.tscn")
const INSTITUTION_DELEGATE = preload("res://src/UIComponents/InstitutionDelegate.tscn")

@onready var place_1_container: PanelContainer = $VBoxContainer/ScrollContainer/VBoxContainer/Place1
@onready var place_2_container: PanelContainer = $VBoxContainer/ScrollContainer/VBoxContainer/Place2
@onready var place_3_container: PanelContainer = $VBoxContainer/ScrollContainer/VBoxContainer/Place3

@onready var place_1: OptionButton = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Place1/HBoxContainer/Place1
@onready var place_2: OptionButton = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Place2/HBoxContainer/Place2
@onready var place_3: OptionButton = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Place3/HBoxContainer/Place3

@onready var save: Button = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Save

@onready var place_buttons:Array = [
	place_1,
	place_2,
	place_3
	]

var data_to_save:Dictionary = {
	"first_place":{
		"type":"",
		"uid":"",
	},
	"second_place":{
		"type":"",
		"uid":"",
	},
	"third_place":{
		"type":"",
		"uid":"",
	},
}

var uid_type_index:Dictionary = {}

var uid_individual_index:Dictionary = {}
var uid_institution_index:Dictionary = {}
var registrations_loaded:int = 0
func _ready() -> void:
	if Utils.selected_event.size() != 0:
		selected_event = Utils.selected_event.get_front()
		event_id = Utils.event_id.get_front()
		get_individual_registrations()
		get_institution_registrations()
		

func _check_all_registrations_loaded() -> void:
	if registrations_loaded >= 2:
		get_winners()


func get_individual_registrations()->void:
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
		add_individual_registrations(data)
	else:
		if response_code == 404:
			OS.alert("No individual registrations found")
			registrations_loaded += 1
			_check_all_registrations_loaded()
		else:
			push_error("request failed response code: ",response_code)

func get_institution_registrations()->void:
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
			registrations_loaded += 1
			_check_all_registrations_loaded()
		else:
			push_error("request failed response code: ",response_code)

func add_individual_registrations(data:Dictionary)->void:
	var registration_ids:Array[String] = []
	var running_total:int = 0
	INDIVIDUAL_REGISTRATIONS = data
	for i in INDIVIDUAL_REGISTRATIONS["registrations"]:
		registration_ids.append(i["registration_id"])
		uid_type_index[i["registration_id"]] = "individual"
		uid_individual_index[i["registration_id"]] = running_total
		running_total += 1
	for i :OptionButton in place_buttons:
		for j :String in registration_ids:
			i.add_item(j)
	
	registrations_loaded += 1
	_check_all_registrations_loaded()
	
func add_institution_registrations(data:Dictionary)->void:
	var registration_ids:Array[String] = []
	var running_total:int = 0
	INSTITUTION_REGISTRATIONS = data
	for i in INSTITUTION_REGISTRATIONS["registrations"]:
		registration_ids.append(i["registration_id"])
		uid_type_index[i["registration_id"]] = "institution"
		uid_institution_index[i["registration_id"]] = running_total
		running_total += 1
	for i :OptionButton in place_buttons:
		for j :String in registration_ids:
			i.add_item(j)
	
	registrations_loaded += 1
	_check_all_registrations_loaded()
	
func _on_back_pressed() -> void:
	var Go_To_Winners :PackedScene = load("res://src/Main/go_to_winners.tscn")
	get_tree().change_scene_to_packed(Go_To_Winners)

func get_winners()->void:
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self.load_fetched_winners_data)
	http.request_completed.connect(http.queue_free.unbind(4))
	var club = Utils.login_club.uri_encode()
	var event = event_id.uri_encode()
	var url :String= Utils.default_backend_url+"get_winners/"+club+"/"+event
	var err = http.request(url)
	if err != OK:
		push_error("http request error: ",err)
		
func load_fetched_winners_data(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if data != {}:
			data_to_save = data
			parse_fetched_data(data)
	else:
		push_error("request failed response code: ",response_code)

func select_option_by_text(button: OptionButton, text: String) -> void:
	for i in range(button.item_count):
		if button.get_item_text(i) == text:
			button.select(i)
			return


func parse_fetched_data(data:Dictionary) -> void:
	# First Place
	if data.has("first_place") and data["first_place"]["uid"] != "":
		var uid = data["first_place"]["uid"]
		var type = data["first_place"]["type"]

		select_option_by_text(place_1, uid)

		for c in place_1_container.get_children():
			c.queue_free()

		if type == "individual":
			var delegate:Node = INDUVIDUALDELEGATE.instantiate()
			place_1_container.add_child(delegate)
			delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[uid]])
		elif type == "institution":
			var delegate:Node = INSTITUTION_DELEGATE.instantiate()
			place_1_container.add_child(delegate)
			delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[uid]])

	# Second Place
	if data.has("second_place") and data["second_place"]["uid"] != "":
		var uid = data["second_place"]["uid"]
		var type = data["second_place"]["type"]

		select_option_by_text(place_2, uid)

		for c in place_2_container.get_children():
			c.queue_free()

		if type == "individual":
			var delegate:Node = INDUVIDUALDELEGATE.instantiate()
			place_2_container.add_child(delegate)
			delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[uid]])
		elif type == "institution":
			var delegate:Node = INSTITUTION_DELEGATE.instantiate()
			place_2_container.add_child(delegate)
			delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[uid]])

	# Third Place
	if data.has("third_place") and data["third_place"]["uid"] != "":
		var uid = data["third_place"]["uid"]
		var type = data["third_place"]["type"]

		select_option_by_text(place_3, uid)

		for c in place_3_container.get_children():
			c.queue_free()

		if type == "individual":
			var delegate:Node = INDUVIDUALDELEGATE.instantiate()
			place_3_container.add_child(delegate)
			delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[uid]])
		elif type == "institution":
			var delegate:Node = INSTITUTION_DELEGATE.instantiate()
			place_3_container.add_child(delegate)
			delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[uid]])

	
func _on_place_1_item_selected(index: int) -> void:
	if index == 0:
		data_to_save["first_place"] = {
		"type":"",
		"uid":"",
		}
		return
	
	data_to_save["first_place"] = {
		"type":uid_type_index[place_1.get_item_text(index)],
		"uid":place_1.get_item_text(index),
	}
	
	var type:String = uid_type_index[place_1.get_item_text(index)]
	
	for i in place_1_container.get_children():
		i.queue_free()
		
	if type == "individual":
		var delegate:Node = INDUVIDUALDELEGATE.instantiate()
		place_1_container.add_child(delegate)
		delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[place_1.get_item_text(index)]])
		
	elif type == "institution":
		var delegate:Node = INSTITUTION_DELEGATE.instantiate()
		place_1_container.add_child(delegate)
		delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[place_1.get_item_text(index)]])
	else:
		push_error("invalid registration type")

func _on_place_2_item_selected(index: int) -> void:
	if index == 0:
		data_to_save["second_place"] = {
		"type":"",
		"uid":"",
		}
		return
	
	data_to_save["second_place"] = {
		"type":uid_type_index[place_2.get_item_text(index)],
		"uid":place_2.get_item_text(index),
	}
	
	var type:String = uid_type_index[place_2.get_item_text(index)]
	for i in place_2_container.get_children():
		i.queue_free()
	if type == "individual":
		var delegate:Node = INDUVIDUALDELEGATE.instantiate()
		place_2_container.add_child(delegate)
		delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[place_2.get_item_text(index)]])
		
	elif type == "institution":
		var delegate:Node = INSTITUTION_DELEGATE.instantiate()
		place_2_container.add_child(delegate)
		delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[place_2.get_item_text(index)]])
	else:
		push_error("invalid registration type")
		
func _on_place_3_item_selected(index: int) -> void:
	if index == 0:
		data_to_save["third_place"] = {
		"type":"",
		"uid":"",
		}
		return
	
	data_to_save["third_place"] = {
		"type":uid_type_index[place_3.get_item_text(index)],
		"uid":place_3.get_item_text(index),
	}
	
	var type:String = uid_type_index[place_3.get_item_text(index)]
	for i in place_3_container.get_children():
		i.queue_free()
	if type == "individual":
		var delegate:Node = INDUVIDUALDELEGATE.instantiate()
		place_3_container.add_child(delegate)
		delegate._load_data(INDIVIDUAL_REGISTRATIONS["registrations"][uid_individual_index[place_3.get_item_text(index)]])
		
	elif type == "institution":
		var delegate:Node = INSTITUTION_DELEGATE.instantiate()
		place_3_container.add_child(delegate)
		delegate._load_data(INSTITUTION_REGISTRATIONS["registrations"][uid_institution_index[place_3.get_item_text(index)]])
	else:
		push_error("invalid registration type")
		

func _on_save_pressed() -> void:
	var http :HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self.on_save_completed)
	http.request_completed.connect(http.queue_free.unbind(4))
	var header = ["Content-Type: application/json"]
	var body:String = JSON.stringify(data_to_save)
	var url :String= Utils.default_backend_url+"set_winners/"+Utils.login_club.uri_encode()+"/"+event_id.uri_encode()
	
	var err = http.request(url,header,HTTPClient.METHOD_POST,body)
	if err != OK:
		push_error("http request error: ",err)

func on_save_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var data:bool = JSON.parse_string(body.get_string_from_utf8())
		if data == true:
			_on_back_pressed()
	else:
		push_error("request failed response code: ",response_code)
