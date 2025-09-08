extends Node

var login_user_id:String = ""
var login_club:String = ""

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
