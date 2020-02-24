extends Node2D

var LANE_COUNT = 10
var GEM_COUNT = 8

var input_lane_pressed = []

func _ready():
	for i in range(LANE_COUNT):
		input_lane_pressed.append(false)
		if i < GEM_COUNT:
			var off_id
			if i > 3:
				off_id = i - 4
			else:
				off_id = 3 - i
			get_node("Lane" + str(i)).set_off_id(off_id)

	get_node("Lane8").set_type("bar")
	get_node("Lane9").set_type("bar")


func _process(delta):
	var lane_pressed
	for i in range(LANE_COUNT):
		lane_pressed = Input.is_action_pressed("lane_" + str(i))
		if lane_pressed != input_lane_pressed[i]:
			get_node("Lane" + str(i)).set_state(lane_pressed)
		input_lane_pressed[i] = lane_pressed