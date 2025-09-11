extends Node

var login_club:String = ""

var register_form:Queue = Queue.new()
var selected_event:Queue = Queue.new()

var logged_in:bool = false
var user_id:String = ""
var password:String = ""

const SAVE_DIRECTORY = "user://save/"
const SAVE_PATH = "save.tres"

@export var save:save_file = save_file.new()

func _ready() -> void:
	load_data(SAVE_DIRECTORY,SAVE_PATH)

func save_info():
	save.logged_in = logged_in
	save.club_name = login_club
	save.login_id = user_id
	save_data(SAVE_DIRECTORY,SAVE_PATH)
	
func verify_save_directory(directory:String)->void:
	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)

func save_data(directory:String,path:String)->void:
	verify_save_directory(directory)
	ResourceSaver.save(save,directory+path)

func load_data(directory:String,path:String)->void:
	if FileAccess.file_exists(directory+path):
		save = ResourceLoader.load(directory+path)
		apply_data()
		
func apply_data():
	logged_in = save.logged_in
	login_club = save.club_name
	user_id = save.login_id
	
func is_valid_phone_number(phone: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^\\+?\\d{1,4}?[-.\\s]?\\(?\\d{1,3}?\\)?[-.\\s]?\\d{1,4}[-.\\s]?\\d{1,4}[-.\\s]?\\d{1,9}$")
	return regex.search(phone) != null

func is_whitespace(string:String) -> bool:
	var regex :RegEx = RegEx.new()
	regex.compile("^\\s*$")
	return regex.search(string) != null

func has_property(node:Node,property:String):
	for i in node.get_property_list():
		if i.name == property:
			return true
	return false
