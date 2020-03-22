extends Node2D

signal mode_stage
signal mode_menu
signal mode_results

onready var gem_scene = preload("res://common/Gem.tscn")
onready var GemSprite = preload("res://common/GemSprite.gd")

var SCREEN_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var SCREEN_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var STAGE_LEFT = 150
var STAGE_WIDTH = 350
var STAGE_CENTER = STAGE_LEFT + STAGE_WIDTH/2

var LANE_SIZE = 40
var FIRST_LANE = STAGE_LEFT + 10 + LANE_SIZE/2
var LANE_GAP = 10
var LANE_COUNT = 10
var GEM_LANES = 8

var GREEN_LEEWAY_SECS = 0.1
var YELLOW_LEEWAY_SECS = 0.2
var HOLD_PROGRESS_PERIOD = 0.1

var EVALUATE_HEIGHT = 420

var GREEN_POINTS = 100
var YELLOW_POINTS = 50
var GREEN_HOLD_POINTS = 10
var YELLOW_HOLD_POINTS = 5

var PAUSE_ARROW_GAP = 40

var song_file_name = ""
var ogg_file_name = ""
var song_mode
var gem_list = []
var gem_starts = []
var gem_speed = 300
var held_gems = []
var elapsed
var paused = false
var pause_debounce = true
var paused_resume_exitb = true
var lane_input_rising
var lane_input_held
var lane_input_pressed
var score = 0
var gem_count = 0
var green_count = 0
var yellow_count = 0
var red_count = 0
var current_streak = 0
var best_streak = 0

func _ready():
	pass


func init(song_data):
	elapsed = 0
	lane_input_rising = []
	lane_input_held = []
	lane_input_pressed = []
	for i in range(LANE_COUNT):
		lane_input_rising.append(false)
		lane_input_held.append(false)
		lane_input_pressed.append(false)
		if i < GEM_LANES*2:
			var input_sprite = get_node("lane_input_" + str(i%GEM_LANES))
			input_sprite.position.x = get_lane_x(i)
	$bar.position = Vector2(STAGE_CENTER+0.5, EVALUATE_HEIGHT)
	$lane_input_8.position = Vector2(get_lane_x(16), EVALUATE_HEIGHT)
	$lane_input_9.position = Vector2(get_lane_x(18), EVALUATE_HEIGHT)
	$MIDIParser.parse_file(song_data[1])
	gem_starts = $MIDIParser.note_starts
	$MusicPlayer.set_song(song_data[0])
	song_file_name = song_data[2]
	song_mode = song_data[3]
	match song_mode:
		"easy":
			gem_speed = 250
		"medium":
			gem_speed = 300
		"expert":
			gem_speed = 350
		"expertplus":
			gem_speed = 350
	ogg_file_name = song_data[0]


func _process(delta):
	if $MusicPlayer.completed:
		emit_signal("mode_results", [score, gem_count, green_count, yellow_count, red_count, best_streak, song_file_name, song_mode])

	var pressed = Input.is_action_pressed("ui_accept")
	if pressed and not pause_debounce:
		paused = not paused
		$PauseSprites.visible = paused
		$PauseArrow.visible = paused
		if paused:
			$MusicPlayer.pause()
		elif paused_resume_exitb:
			$MusicPlayer.resume()
		else:
			emit_signal("mode_menu")

	if paused:
		if Input.is_action_pressed("ui_up") and not paused_resume_exitb:
			paused_resume_exitb = true
			$PauseArrow.position.y -= PAUSE_ARROW_GAP
		elif Input.is_action_pressed("ui_down") and paused_resume_exitb:
			paused_resume_exitb = false
			$PauseArrow.position.y += PAUSE_ARROW_GAP
	else:
		elapsed = $MusicPlayer.get_position()
		spawn_gems()
		advance_gems()
		update_inputs()
		check_gems()
		$ScoreDisplay.text = str(score)
		$StreakDisplay.text = str(current_streak)
	pause_debounce = pressed


func spawn_gems():
	var hit_time
	var hold_end
	for i in range(gem_starts.size()-1, -1, -1):
		hit_time = $MIDIParser.beats_to_secs(gem_starts[i][1])
		hold_end = $MIDIParser.beats_to_secs(gem_starts[i][2])
		if (elapsed - hit_time) * gem_speed + EVALUATE_HEIGHT > -32:
			spawn_gem(gem_starts[i][0], hit_time, hold_end)
			gem_starts.remove(i)


func spawn_gem(lane_number, hit_time, hold_end):
	var gem = gem_scene.instance()
	add_child(gem)
	gem.position = Vector2(get_lane_x(lane_number), -gem.gem_size().y/2)
	if lane_number < GEM_LANES * 2:
		gem.lane_number = lane_number%GEM_LANES
		gem.z_index = 4
		if gem.lane_number > 3:
			gem.set_off_id(gem.lane_number - 4)
		else:
			gem.set_off_id(gem.lane_number)
		if lane_number >= GEM_LANES:
			gem.set_hold((hold_end - hit_time) * gem_speed)
	else:
		gem.lane_number = lane_number/2
		gem.set_type(GemSprite.Type.BAR)
		gem.z_index = 3
		if lane_number % 2 == 1:
			gem.set_hold((hold_end - hit_time) * gem_speed)
	gem.hit_time = hit_time
	gem_list.append(gem)
	gem_count += 1


func get_lane_x(lane_number):
	if lane_number < 16:
		var x_pos = lane_number%GEM_LANES * LANE_SIZE + FIRST_LANE
		if lane_number%GEM_LANES >= GEM_LANES/2:
			x_pos += LANE_GAP
		return x_pos
	elif lane_number < 18:
		return STAGE_CENTER - ((STAGE_CENTER - STAGE_LEFT) / 2) + 2
	else:
		return STAGE_CENTER + ((STAGE_CENTER - STAGE_LEFT) / 2) - 1


func advance_gems():
	var gem
	for i in range(gem_list.size()):
		gem = gem_list[i]
		gem.position.y = (elapsed - gem.hit_time) * gem_speed + EVALUATE_HEIGHT


func update_inputs():
	var lane_pressed
	for i in range(LANE_COUNT):
		lane_pressed = Input.is_action_pressed("lane_" + str(i))
		lane_input_rising[i] = not lane_input_pressed[i] and lane_pressed
		lane_input_held[i] = lane_input_pressed[i] and lane_pressed

		lane_input_pressed[i] = lane_pressed
		get_node("lane_input_" + str(i)).visible = lane_pressed


func check_gems():
	var gem
	var lanes_used = []
	for i in range(LANE_COUNT):
		lanes_used.append(false)
	var remove_indices = []
	var held_remove_indices = []

	for i in range(held_gems.size()):
		gem = held_gems[i]
		if gem.hold_complete:
			held_remove_indices.append(i)
		elif lane_input_held[gem.lane_number]:
			gem.update_tail(gem.position.y-EVALUATE_HEIGHT)
			while gem.hold_progress_time < elapsed - gem.hit_time and gem.hold_progress_time < gem.note_length:
				if gem.current_state == GemSprite.State.GREEN:
					score += GREEN_HOLD_POINTS
				elif gem.current_state == GemSprite.State.YELLOW:
					score += YELLOW_HOLD_POINTS
				gem.hold_progress_time += HOLD_PROGRESS_PERIOD
		else:
			current_streak = 0
			held_remove_indices.append(i)

	for i in range(gem_list.size()):
		gem = gem_list[i]

		if not gem.is_evaluated and lane_input_rising[gem.lane_number] and not lanes_used[gem.lane_number]:
			if abs(elapsed-gem.hit_time) < GREEN_LEEWAY_SECS:
				green_hit(gem, lanes_used)
			elif abs(elapsed-gem.hit_time) < YELLOW_LEEWAY_SECS:
				yellow_hit(gem, lanes_used)

		if not gem.is_evaluated and elapsed-gem.hit_time > YELLOW_LEEWAY_SECS:
			red_hit(gem)
		
		if gem.position.y - gem.note_length > SCREEN_HEIGHT + gem.gem_size().y/2:
			remove_child(gem)
			remove_indices.append(i)

	for i in range(remove_indices.size()-1, -1, -1):
		gem_list.remove(remove_indices[i])

	for i in range(held_remove_indices.size()-1, -1, -1):
		held_gems.remove(held_remove_indices[i])


func green_hit(gem, lanes_used):
	gem.set_state(GemSprite.State.GREEN)
	lanes_used[gem.lane_number] = true
	if gem.is_hold:
		held_gems.append(gem)
	score += GREEN_POINTS
	green_count += 1
	current_streak += 1
	if current_streak > best_streak:
		best_streak = current_streak


func yellow_hit(gem, lanes_used):
	gem.set_state(GemSprite.State.YELLOW)
	lanes_used[gem.lane_number] = true
	if gem.is_hold:
		held_gems.append(gem)
	score += YELLOW_POINTS
	yellow_count += 1
	current_streak += 1
	if current_streak > best_streak:
		best_streak = current_streak


func red_hit(gem):
	gem.set_state(GemSprite.State.RED)
	red_count += 1
	current_streak = 0
