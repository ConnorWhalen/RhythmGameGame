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

var EVALUATE_HEIGHT = 420

var SCREEN_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var SCREEN_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

var gem_list = []
var gem_starts = [[2, 3.0], [3, 3.0], [4, 3.5],
				  [0, 4.0], [4, 4.5], [2, 5.0], [4, 5.5], [1, 6.0], [4, 6.5], [2, 7.0], [4, 7.5],
				  [0, 8.0], [5, 8.5], [2, 9.0], [5, 9.5], [1,10.0], [5,10.5], [2,11.0], [5,11.5]]
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
	$bar.position = Vector2(SCREEN_WIDTH/2, EVALUATE_HEIGHT)


func _process(delta):
	elapsed = $MusicPlayer.get_position()
	spawn_gems()
	advance_gems()
	update_inputs()
	check_gems()


func spawn_gems():
	var hit_time
	for i in range(gem_starts.size()-1, -1, -1):
		hit_time = $MusicPlayer.beats_to_secs(gem_starts[i][1])
		print(str(gem_starts[i][1]) + " " + str(hit_time))
		if (elapsed - hit_time) * GEM_SPEED + EVALUATE_HEIGHT > -32:
			print((elapsed - hit_time) * GEM_SPEED + EVALUATE_HEIGHT)
			spawn_gem(gem_starts[i][0], hit_time)
			gem_starts.remove(i)


func spawn_gem(lane_number, hit_time):
	var gem = gem_scene.instance()
	add_child(gem)
	gem.position = Vector2(get_lane_x(lane_number), -gem.gem_size().y/2)
	gem.lane_number = lane_number
	gem.hit_time = hit_time
	gem_list.append(gem)


func get_lane_x(lane_number):
	var x_pos = lane_number * LANE_SIZE + FIRST_LANE
	if lane_number >= LANE_COUNT/2:
		x_pos += LANE_GAP
	return x_pos


func advance_gems():
	var gem
	for i in range(gem_list.size()):
		gem = gem_list[i]
		gem.position.y = (elapsed - gem.hit_time) * GEM_SPEED + EVALUATE_HEIGHT


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
	for i in range(gem_list.size()-1, -1, -1):
		gem = gem_list[i]

		if not gem.is_evaluated and lane_input_rising[gem.lane_number]:
			if abs(elapsed-gem.hit_time) < GREEN_LEEWAY_SECS:
				gem.set_state(GemSprite.State.GREEN)
			elif abs(elapsed-gem.hit_time) < YELLOW_LEEWAY_SECS:
				gem.set_state(GemSprite.State.YELLOW)

		if not gem.is_evaluated and elapsed-gem.hit_time > YELLOW_LEEWAY_SECS:
			gem.set_state(GemSprite.State.RED)
		
		if gem.position.y > SCREEN_HEIGHT + gem.gem_size().y/2:
			remove_child(gem)
			gem_list.remove(i)

	
