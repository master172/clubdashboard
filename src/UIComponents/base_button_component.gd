extends Button
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var label: Label = $MarginContainer/VBoxContainer/Label

@export var Icon:Texture
@export var Text:String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Icon != null:
		texture_rect.texture = Icon
	if Text != "":
		label.text = Text
