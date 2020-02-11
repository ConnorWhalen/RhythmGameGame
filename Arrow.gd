extends Sprite

onready var Menu = preload("res://Menu.gd")


var SETTINGS_POSITION = Vector2(328, 435)
var SETTINGS_ROTATION = 23.2
var PLAYSONG_POSITION = Vector2(287, 439)
var PLAYSONG_ROTATION = 152.8


func _ready():
	set_state(Menu.Option.PLAYSONG)


func set_state(state):
	match state:
		Menu.Option.SETTINGS:
			position = SETTINGS_POSITION
			rotation_degrees = SETTINGS_ROTATION
		Menu.Option.PLAYSONG:
			position = PLAYSONG_POSITION
			rotation_degrees = PLAYSONG_ROTATION
