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
var off_id

var current_state
var current_sprite
var current_middle
var current_middle_scale
var current_tail
var current_off_sprite
var current_off_middle
var current_off_middle_scale
var current_off_tail
var is_pressed
var pressed_time
var hold_complete
var hold_progress_time

func _ready():
	is_evaluated = false
	current_state = State.OFF
	current_off_sprite = $OffGem0
	current_off_middle = $OffMiddle0
	current_off_middle_scale = current_off_middle.scale.y
	current_off_tail = $OffTail0
	current_sprite = current_off_sprite
	current_middle = current_off_middle
	current_middle_scale = current_middle.scale.y
	current_tail = current_off_tail
	current_type = Type.GEM
	is_pressed = false
	pressed_time = 0
	is_hold = false
	note_length = 0
	hold_complete = false
	hold_progress_time = 0
	off_id = 0


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
			current_off_middle = $OffMiddleBar
			current_off_tail = $OffTailBar
			current_middle = current_off_middle
			current_tail = current_off_tail
			current_off_middle_scale = current_off_middle.scale.y
			current_middle_scale = current_middle.scale.y


func set_hold(length):
	is_hold = true
	note_length = length
	current_off_tail.position.y = -length
	current_off_middle.position.y = -length/2
	current_off_middle.scale.y = (length/32) * current_off_middle_scale
	current_off_tail.visible = true
	current_off_middle.visible = true


func set_off_id(_off_id):
	off_id = _off_id
	current_off_sprite.visible = false

	current_off_sprite = get_node("OffGem" + str(off_id))
	current_off_middle = get_node("OffMiddle" + str(off_id))
	current_off_tail = get_node("OffTail" + str(off_id))
	current_off_middle_scale = current_off_middle.scale.y
	if current_state == State.OFF:
		current_sprite = current_off_sprite
		current_middle = current_off_middle
		current_tail = current_off_tail
		current_middle_scale = current_off_middle_scale

	current_off_sprite.visible = true


func update_tail(progress):
	if current_state != State.OFF and current_state != State.RED and progress > 0:
		if progress > note_length:
			current_off_middle.visible = false
			current_off_tail.visible = false
			current_middle.visible = true
			current_tail.visible = true

			current_tail.position.y = -note_length
			current_middle.position.y = -note_length/2
			current_middle.scale.y = (note_length/32) * current_middle_scale
			hold_complete = true
		else:
			current_off_middle.visible = true
			current_off_tail.visible = true
			current_middle.visible = true
			current_tail.visible = false

			current_off_tail.position.y = -note_length
			current_off_middle.position.y = -note_length + (note_length-progress)/2
			current_off_middle.scale.y = ((note_length-progress)/32) * current_off_middle_scale
			current_middle.position.y = -progress/2
			current_middle.scale.y = (progress/32) * current_middle_scale


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
			current_middle_scale = current_middle.scale.y
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
			current_middle_scale = current_middle.scale.y
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
			current_middle_scale = current_middle.scale.y
			current_tail = $RedTail
			is_evaluated = true
		State.OFF:
			match current_type:
				Type.GEM:
					current_sprite = current_off_sprite
				Type.BAR:
					current_sprite = $BarOffGem
			is_evaluated = false
	current_sprite.visible = true
	current_state = state

