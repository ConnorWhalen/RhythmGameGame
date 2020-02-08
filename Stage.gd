extends Node2D

onready var gem_scene = preload("res://Gem.tscn")
onready var GemSprite = preload("res://GemSprite.gd")

var LANE_SIZE = 40
var FIRST_LANE = 10 + 16
var LANE_GAP = 40
var LANE_COUNT = 6

var GEM_SPEED = 200
var GREEN_LEEWAY_SECS = 0.1
var YELLOW_LEEWAY_SECS = 0.2
var GREEN_LEEWAY_DISTANCE = GEM_SPEED * GREEN_LEEWAY_SECS
var YELLOW_LEEWAY_DISTANCE = GEM_SPEED * YELLOW_LEEWAY_SECS

var EVALUATE_GREEN_TOP = 420 - GREEN_LEEWAY_DISTANCE
var EVALUATE_GREEN_BOTTOM = 420 + GREEN_LEEWAY_DISTANCE
var EVALUATE_YELLOW_TOP = 420 - YELLOW_LEEWAY_DISTANCE
var EVALUATE_YELLOW_BOTTOM = 420 + YELLOW_LEEWAY_DISTANCE
var CLEAR_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

var gem_list = []
var gem_starts = [[0, 2], [1, 3], [2, 3.5], [3, 4], [4, 5], [5, 5.5]]
var elapsed
var lane_input_rising
var lane_input_pressed

func _ready():
	elapsed = 0
	lane_input_rising = []
	lane_input_pressed = []
	for i in range(LANE_COUNT):
		lane_input_rising.append(false)
		lane_input_pressed.append(false)
		var input_sprite = get_node("lane_input_" + str(i))
		input_sprite.position.x = get_lane_x(i)


func _process(delta):
	elapsed += delta
	spawn_gems()
	advance_gems(delta)
	update_inputs()
	check_gems()


func spawn_gems():
	for i in range(gem_starts.size()-1, -1, -1):
		if elapsed > gem_starts[i][1]:
			spawn_gem(gem_starts[i][0])
			gem_starts.remove(i)


func spawn_gem(lane_number):
	var gem = gem_scene.instance()
	add_child(gem)
	gem.position = Vector2(get_lane_x(lane_number), -gem.gem_size().y/2)
	gem_list.append([gem, lane_number])


func get_lane_x(lane_number):
	var x_pos = lane_number * LANE_SIZE + FIRST_LANE
	if lane_number >= LANE_COUNT/2:
		x_pos += LANE_GAP
	return x_pos


func advance_gems(delta):
	var gem
	for i in range(gem_list.size()):
		gem = gem_list[i][0]
		gem.position.y += delta * GEM_SPEED


func update_inputs():
	var lane_pressed
	for i in range(LANE_COUNT):
		lane_pressed = Input.is_action_pressed("lane_" + str(i))
		if lane_input_pressed[i] == false and lane_pressed:
			lane_input_rising[i] = true
		else:
			lane_input_rising[i] = false

		lane_input_pressed[i] = lane_pressed
		get_node("lane_input_" + str(i)).visible = lane_pressed


func check_gems():
	var gem
	var lane_number
	for i in range(gem_list.size()-1, -1, -1):
		gem = gem_list[i][0]
		lane_number = gem_list[i][1]

		if not gem.is_evaluated and lane_input_rising[lane_number]:
			if gem.position.y >= EVALUATE_YELLOW_TOP and gem.position.y < EVALUATE_GREEN_TOP:
				gem.set_state(GemSprite.State.YELLOW)
			elif gem.position.y >= EVALUATE_GREEN_TOP and gem.position.y < EVALUATE_GREEN_BOTTOM:
				gem.set_state(GemSprite.State.GREEN)
			if gem.position.y >= EVALUATE_GREEN_BOTTOM and gem.position.y < EVALUATE_YELLOW_BOTTOM:
				gem.set_state(GemSprite.State.YELLOW)

		if not gem.is_evaluated and gem.position.y > EVALUATE_YELLOW_BOTTOM:
			gem.set_state(GemSprite.State.RED)
		
		if gem.position.y > CLEAR_HEIGHT + gem.gem_size().y/2:
			remove_child(gem)
			gem_list.remove(i)

	
