extends Node2D

enum State {
	GREEN,
	YELLOW,
	RED,
	OFF
}

enum Type {
	GEM,
	BAR
}

var PRESS_SECONDS = 0.15

var current_type
var is_evaluated
var lane_number
var hit_time

var current_state
var current_sprite
var is_pressed
var pressed_time

func _ready():
	is_evaluated = false
	current_sprite = $OffGem
	current_type = Type.GEM
	is_pressed = false
	pressed_time = 0


func _process(delta):
	if is_pressed:
		pressed_time += delta
		if pressed_time > PRESS_SECONDS:
			is_pressed = false
			pressed_time = 0
			current_sprite.visible = false
			match current_state:
				State.GREEN:
					match current_type:
						Type.GEM:
							current_sprite = $GreenGem
						Type.BAR:
							current_sprite = $BarGreenGem
				State.YELLOW:
					match current_type:
						Type.GEM:
							current_sprite = $YellowGem
						Type.BAR:
							current_sprite = $BarYellowGem
			current_sprite.visible = true


func gem_size():
	return current_sprite.texture.region.size


func set_state(state):
	current_sprite.visible = false
	match state:
		State.GREEN:
			match current_type:
				Type.GEM:
					current_sprite = $GreenGemPressed
				Type.BAR:
					current_sprite = $BarGreenGemPressed
			is_evaluated = true
			is_pressed = true
		State.YELLOW:
			match current_type:
				Type.GEM:
					current_sprite = $YellowGemPressed
				Type.BAR:
					current_sprite = $BarYellowGemPressed
			is_evaluated = true
			is_pressed = true
		State.RED:
			match current_type:
				Type.GEM:
					current_sprite = $RedGem
				Type.BAR:
					current_sprite = $BarRedGem
			is_evaluated = true
		State.OFF:
			match current_type:
				Type.GEM:
					current_sprite = $OffGem
				Type.BAR:
					current_sprite = $BarOffGem
			is_evaluated = false
	current_sprite.visible = true
	current_state = state

func set_type(type):
	current_type = type
	current_sprite.visible = false
	current_sprite = $BarOffGem
	current_sprite.visible = true