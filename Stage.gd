extends Node2D

signal mode_stage
signal mode_menu

onready var gem_scene = preload("res://Gem.tscn")
onready var GemSprite = preload("res://GemSprite.gd")

var LANE_SIZE = 40
var FIRST_LANE = 160 + 20
var LANE_GAP = 40
var LANE_COUNT = 7

var GEM_SPEED = 200
var GREEN_LEEWAY_SECS = 0.1
var YELLOW_LEEWAY_SECS = 0.2

var EVALUATE_HEIGHT = 420

var SCREEN_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var SCREEN_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

var gem_list = []
var gem_starts = []
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
		if i < 6:
			var input_sprite = get_node("lane_input_" + str(i))
			input_sprite.position.x = get_lane_x(i)
	$bar.position = Vector2(SCREEN_WIDTH/2, EVALUATE_HEIGHT)
	$lane_input_6.position = Vector2(SCREEN_WIDTH/2, EVALUATE_HEIGHT)
	$MIDIParser.parse_file("res://songs/weekend fan club.mid")
	gem_starts = $MIDIParser.note_starts
	$MusicPlayer.set_song("res://songs/weekend-fan-club-third-copy.ogg")


func _process(delta):
	if $MusicPlayer.completed:
		emit_signal("mode_menu")
	elapsed = $MusicPlayer.get_position()
	spawn_gems()
	advance_gems()
	update_inputs()
	check_gems()


func spawn_gems():
	var hit_time
	for i in range(gem_starts.size()-1, -1, -1):
		hit_time = $MIDIParser.beats_to_secs(gem_starts[i][1])
		if (elapsed - hit_time) * GEM_SPEED + EVALUATE_HEIGHT > -32:
			spawn_gem(gem_starts[i][0], hit_time)
			gem_starts.remove(i)


func spawn_gem(lane_number, hit_time):
	var gem = gem_scene.instance()
	add_child(gem)
	if lane_number < 6:
		gem.position = Vector2(get_lane_x(lane_number), -gem.gem_size().y/2)
		gem.z_index = 2
	else:
		gem.position = Vector2(SCREEN_WIDTH/2, -gem.gem_size().y/2)
		gem.set_type(GemSprite.Type.BAR)
		gem.z_index = 1
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
	var lanes_used = []
	for i in range(LANE_COUNT):
		lanes_used.append(false)
	var remove_indices = []

	for i in range(gem_list.size()):
		gem = gem_list[i]

		if not gem.is_evaluated and lane_input_rising[gem.lane_number] and not lanes_used[gem.lane_number]:
			if abs(elapsed-gem.hit_time) < GREEN_LEEWAY_SECS:
				gem.set_state(GemSprite.State.GREEN)
				lanes_used[gem.lane_number] = true
			elif abs(elapsed-gem.hit_time) < YELLOW_LEEWAY_SECS:
				gem.set_state(GemSprite.State.YELLOW)
				lanes_used[gem.lane_number] = true

		if not gem.is_evaluated and elapsed-gem.hit_time > YELLOW_LEEWAY_SECS:
			gem.set_state(GemSprite.State.RED)
		
		if gem.position.y > SCREEN_HEIGHT + gem.gem_size().y/2:
			remove_child(gem)
			remove_indices.append(i)

	for i in range(remove_indices.size()-1, -1, -1):
		gem_list.remove(remove_indices[i])
