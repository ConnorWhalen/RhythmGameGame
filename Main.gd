extends Node2D

enum Mode {
	STAGE,
	MENU
}

signal mode_stage(song_data)
signal mode_menu

onready var stage_scene = preload("res://Stage.tscn")
onready var menu_scene = preload("res://Menu.tscn")

var current_mode_id
var current_mode

func _ready():
	set_mode(Mode.MENU, null)

func set_mode(mode_id, data):
	remove_child(current_mode)
	current_mode_id = mode_id
	match current_mode_id:
		Mode.STAGE:
			current_mode = stage_scene.instance()
			current_mode.init(data)
		Mode.MENU:
			current_mode = menu_scene.instance()
	add_child(current_mode)
	current_mode.connect("mode_stage", self, "set_mode_stage")
	current_mode.connect("mode_menu", self, "set_mode_menu")

func set_mode_stage(song_data):
	set_mode(Mode.STAGE, song_data)

func set_mode_menu():
	set_mode(Mode.MENU, null)
