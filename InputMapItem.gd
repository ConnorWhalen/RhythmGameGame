extends Node2D

onready var gem_scene = preload("res://Gem.tscn")
onready var GemSprite = preload("res://GemSprite.gd")

var gem

func _ready():
	gem = gem_scene.instance()
	gem.position = Vector2(0, -45)
	add_child(gem)


func set_state(on_offb):
	if on_offb:
		gem.set_state(GemSprite.State.GREEN)
	else:
		gem.set_state(GemSprite.State.OFF)


func set_type(t):
	if t == "bar":
		gem.set_type(GemSprite.Type.BAR)
	elif t == "gem":
		gem.set_type(GemSprite.Type.GEM)


func set_off_id(off_id):
	gem.set_off_id(off_id)
