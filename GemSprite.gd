extends Node2D

enum State {
	GREEN,
	YELLOW,
	RED,
	OFF
}

var is_evaluated
var current_sprite

func _ready():
	is_evaluated = false
	current_sprite = $OffGem


func _process(delta):
	pass


func gem_size():
	return current_sprite.texture.region.size


func set_state(state):
	current_sprite.visible = false
	match state:
		State.GREEN:
			current_sprite = $GreenGem
			is_evaluated = true
		State.YELLOW:
			current_sprite = $YellowGem
			is_evaluated = true
		State.RED:
			current_sprite = $RedGem
			is_evaluated = true
		State.OFF:
			current_sprite = $OffGem
			is_evaluated = false
	current_sprite.visible = true
