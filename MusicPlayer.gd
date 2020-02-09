extends AudioStreamPlayer


var BPM = 105
var wait_secs = 2
var wait_progress = 0
var started = false


func _ready():
	pass


func _process(delta):
	if not started:
		wait_progress += delta
		if wait_progress >= wait_secs:
			play()
			started = true


func get_position():
	if not started:
		return wait_progress - wait_secs
	else:
		return get_playback_position()


func beats_to_secs(beat):
	return (beat/BPM) * 60
