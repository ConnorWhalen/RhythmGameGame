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
var is_hold
var is_evaluated
var lane_number
var hit_time
var note_length

var current_state
var current_sprite
var current_middle
var current_tail
var is_pressed
var pressed_time
var hold_complete
var hold_progress_time

func _ready():
	is_evaluated = false
	current_state = State.OFF
	current_sprite = $OffGem
	current_middle = $OffMiddle
	current_tail = $OffTail
	current_type = Type.GEM
	is_pressed = false
	pressed_time = 0
	is_hold = false
	note_length = 0
	hold_complete = false
	hold_progress_time = 0


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

func set_type(type):
	current_type = type
	current_sprite.visible = false
	match type:
		Type.GEM:
			current_sprite = $OffGem
			current_sprite.visible = true
		Type.BAR:
			current_sprite = $BarOffGem
			current_sprite.visible = true


func set_hold(length):
	is_hold = true
	note_length = length
	$OffTail.position.y = -length
	$OffMiddle.position.y = -length/2
	$OffMiddle.scale.y = length/30
	$OffTail.visible = true
	$OffMiddle.visible = true


func update_tail(progress):
	if current_state != State.OFF and current_state != State.RED and progress > 0:
		if progress > note_length:
			$OffMiddle.visible = false
			$OffTail.visible = false
			current_middle.visible = true
			current_tail.visible = true

			current_tail.position.y = -note_length
			current_middle.position.y = -note_length/2
			current_middle.scale.y = note_length/30
			hold_complete = true
		else:
			$OffMiddle.visible = true
			$OffTail.visible = true
			current_middle.visible = true
			current_tail.visible = false

			$OffTail.position.y = -note_length
			$OffMiddle.position.y = -note_length + (note_length-progress)/2
			$OffMiddle.scale.y = (note_length-progress)/30
			current_middle.position.y = -progress/2
			current_middle.scale.y = progress/30


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
			current_middle = $GreenMiddle
			current_tail = $GreenTail
			is_evaluated = true
			is_pressed = true
		State.YELLOW:
			match current_type:
				Type.GEM:
					current_sprite = $YellowGemPressed
				Type.BAR:
					current_sprite = $BarYellowGemPressed
			current_middle = $YellowMiddle
			current_tail = $YellowTail
			is_evaluated = true
			is_pressed = true
		State.RED:
			match current_type:
				Type.GEM:
					current_sprite = $RedGem
				Type.BAR:
					current_sprite = $BarRedGem
			current_middle = $RedMiddle
			current_tail = $RedTail
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

