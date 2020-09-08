extends Sprite

onready var Menu = preload("res://menu/Menu.gd")


var SETTINGS_POSITION = Vector2(500, 403)
var SETTINGS_ROTATION = 90
var PLAYSONG_POSITION = Vector2(300, 456)
var PLAYSONG_ROTATION = -90
var HOWTO_POSITION = Vector2(100, 403)
var HOWTO_ROTATION = 90


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
		Menu.Option.HOWTO:
			position = HOWTO_POSITION
			rotation_degrees = HOWTO_ROTATION
