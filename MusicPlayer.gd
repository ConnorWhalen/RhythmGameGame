extends AudioStreamPlayer


var previous_playback_position

var started = false
var finished = false
var completed = false


func _ready():
	$start_timer.start()


func _process(delta):
	if is_playing():
		previous_playback_position = get_playback_position()



func get_position():
	if not started:
		return - $start_timer.time_left
	elif not finished:
		return get_playback_position()
	else:
		return previous_playback_position + $end_timer.wait_time - $end_timer.time_left


func set_song(filename):
	var vstream = load(filename)
	set_stream(vstream)


func _on_start_timer_timeout():
	play()
	started = true


func _on_MusicPlayer_finished():
	$end_timer.start()
	finished = true


func _on_end_timer_timeout():
	completed = true
