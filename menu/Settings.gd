extends Node2D

onready var gem_scene = preload("res://common/Gem.tscn")
onready var GemSprite = preload("res://common/GemSprite.gd")

signal mode_menu

enum Settings {
	NOTE_HEIGHT,
	NOTE_WIDTH,
	NOTE_DIRECTION,
	ADJUST_LAG
}

var SCREEN_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

var ARROW_HEIGHTS = [215, 256, 304, 356]
var BPM = 110.0

var note_scale_x = 1.0
var note_scale_y = 1.0
var note_direction = false
var lag_ms = 0

var current_selection = 0
var gems = []
var GEM_COUNT = 4
var gem_speed

var elapsed = 0
var play_buffer = 0

var up_debounce = true
var down_debounce = true
var left_debounce = true
var right_debounce = true
var enter_debounce = true
var p_debounce = true


func _ready():
	note_scale_x = Save.get_setting(Save.NOTE_SCALE_X)
	note_scale_y = Save.get_setting(Save.NOTE_SCALE_Y)
	note_direction = Save.get_setting(Save.INVERT_Y)
	lag_ms = Save.get_setting(Save.NOTE_DELAY)

	gem_speed = Save.get_setting(Save.NOTE_SPEED) * 250
	for i in range(GEM_COUNT):
		var gem = gem_scene.instance()
		gems.append(gem)
		$Invertible.add_child(gem)
		gem.position.x = 500
		gem.set_off_id(i)
		gem.hit_time = i * (60.0 / BPM)
		gem.z_index = 3
		gem.visible = false

	set_note_scale_x()
	set_note_scale_y()
	set_note_direction()
	set_lag_ms()


func _process(delta):
	var up_pressed = Input.is_action_pressed("ui_up")
	var down_pressed = Input.is_action_pressed("ui_down")
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")
	var enter_pressed = Input.is_action_pressed("ui_accept")
	var p_pressed = Input.is_action_pressed("lane_7")

	if not up_debounce and up_pressed:
		if current_selection == 0:
			current_selection = ARROW_HEIGHTS.size() - 1
		else:
			current_selection -= 1
		set_current_selection()
	elif not down_debounce and down_pressed:
		if current_selection == ARROW_HEIGHTS.size() - 1:
			current_selection = 0
		else:
			current_selection += 1
		set_current_selection()
	elif not left_debounce and left_pressed:
		match current_selection:
			Settings.NOTE_WIDTH:
				if note_scale_x > Save.NOTE_SCALE_MIN:
					note_scale_x -= 0.1
					set_note_scale_x()
			Settings.NOTE_HEIGHT:
				if note_scale_y > Save.NOTE_SCALE_MIN:
					note_scale_y -= 0.1
					set_note_scale_y()
			Settings.NOTE_DIRECTION:
				note_direction = not note_direction
				set_note_direction()
			Settings.ADJUST_LAG:
				lag_ms -= 1
				set_lag_ms()
	elif not right_debounce and right_pressed:
		match current_selection:
			Settings.NOTE_WIDTH:
				if note_scale_x < Save.NOTE_SCALE_MAX:
					note_scale_x += 0.1
					set_note_scale_x()
			Settings.NOTE_HEIGHT:
				if note_scale_y < Save.NOTE_SCALE_MAX:
					note_scale_y += 0.1
					set_note_scale_y()
			Settings.NOTE_DIRECTION:
				note_direction = not note_direction
				set_note_direction()
			Settings.ADJUST_LAG:
				lag_ms += 1
				set_lag_ms()

	if not enter_debounce and enter_pressed:
		emit_signal("mode_menu")

	if current_selection == Settings.ADJUST_LAG:
		elapsed = $BeatPlayer.get_playback_position()
		for i in range(GEM_COUNT):
			var gem = gems[i]
			gem.position.y = elapsed - gem.hit_time + (lag_ms/1000.0)
			gem.position.y *= gem_speed
			gem.position.y += 375

			var note_distance = elapsed - gem.hit_time + (lag_ms/1000.0)
			if not p_debounce and p_pressed and not gem.is_evaluated:
				if abs(note_distance) < Save.CONST_NOTE_LEEWAY_GREEN_SECS:
					gem.set_state(GemSprite.State.GREEN)
				elif abs(note_distance) < Save.CONST_NOTE_LEEWAY_YELLOW_SECS:
					gem.set_state(GemSprite.State.YELLOW)


			if play_buffer > 0:
				play_buffer -= 1
			else:
				if not gem.is_evaluated and note_distance > Save.CONST_NOTE_LEEWAY_YELLOW_SECS:
					gem.set_state(GemSprite.State.RED)
				if gem.position.y > SCREEN_HEIGHT:
					gem.set_state(GemSprite.State.OFF)
					gem.hit_time += 240.0 / BPM


	up_debounce = up_pressed
	down_debounce = down_pressed
	left_debounce = left_pressed
	right_debounce = right_pressed
	enter_debounce = enter_pressed
	p_debounce = p_pressed


func set_current_selection():
	$SettingsArrow.position.y = ARROW_HEIGHTS[current_selection]
	if current_selection == Settings.ADJUST_LAG:
		$BeatPlayer.play(0)
		for i in range(GEM_COUNT):
			var gem = gems[i]
			gem.visible = true
			gem.set_state(GemSprite.State.OFF)
			gem.hit_time = i * (60.0 / BPM)
	else:
		$BeatPlayer.stop()
		play_buffer = 10
		for gem in gems:
			gem.visible = false


func set_note_scale_x():
	$ScaleGem.scale.x = note_scale_x
	for gem in gems:
		gem.scale.x = note_scale_x
	$NoteWidth.text = "%.1f" % note_scale_x
	Save.store_setting(Save.NOTE_SCALE_X, note_scale_x)


func set_note_scale_y():
	$ScaleGem.scale.y = note_scale_y
	for gem in gems:
		gem.scale.y = note_scale_y
	$NoteHeight.text = "%.1f" % note_scale_y
	Save.store_setting(Save.NOTE_SCALE_Y, note_scale_y)


func set_note_direction():
	Save.store_setting(Save.INVERT_Y, note_direction)
	if note_direction:
		$NoteDirection.text = "Up"
		$Invertible.scale.y = -1
		$Invertible.position.y = SCREEN_HEIGHT
	else:
		$NoteDirection.text = "Down"
		$Invertible.scale.y = 1
		$Invertible.position.y = 0


func set_lag_ms():
	Save.store_setting(Save.NOTE_DELAY, lag_ms)
	$AdjustLagMs.text = str(lag_ms)
