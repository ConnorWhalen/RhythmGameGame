extends Node2D

enum Mode {
	STAGE,
	MENU,
	RESULTS,
	SETTINGS,
}

signal mode_stage(song_data)
signal mode_menu
signal mode_results(results_data)
signal mode_settings()

onready var stage_scene = preload("res://stage/Stage.tscn")
onready var menu_scene = preload("res://menu/Menu.tscn")
onready var results_scene = preload("res://results/Results.tscn")
onready var settings_scene = preload("res://menu/Settings.tscn")

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
		Mode.RESULTS:
			current_mode = results_scene.instance()
			current_mode.init(data)
		Mode.SETTINGS:
			current_mode = settings_scene.instance()
	add_child(current_mode)
	current_mode.connect("mode_stage", self, "set_mode_stage")
	current_mode.connect("mode_menu", self, "set_mode_menu")
	current_mode.connect("mode_results", self, "set_mode_results")
	current_mode.connect("mode_settings", self, "set_mode_settings")

func set_mode_stage(song_data):
	set_mode(Mode.STAGE, song_data)

func set_mode_menu():
	set_mode(Mode.MENU, null)

func set_mode_results(results_data):
	set_mode(Mode.RESULTS, results_data)

func set_mode_settings():
	set_mode(Mode.SETTINGS, null)
