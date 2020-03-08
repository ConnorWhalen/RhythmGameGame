extends AudioStreamPlayer

var start_timer_position
var previous_playback_position
var end_timer_position

var started = false
var finished = false
var completed = false

var paused = false


func _ready():
	$start_timer.start()


func _process(delta):
	if $start_timer.is_stopped():
		start_timer_position = $start_timer
	if is_playing():
		previous_playback_position = get_playback_position()


func pause():
	if not started:
		$start_timer.set_paused(true)
	elif not finished:
		set_stream_paused(true)
	else:
		$end_timer.set_paused(true)


func resume():
	if not started:
		$start_timer.set_paused(false)
	elif not finished:
		set_stream_paused(false)
	else:
		$end_timer.set_paused(false)


func get_position():
	if not started:
		return - $start_timer.time_left
	elif not finished:
		return get_playback_position()
	else:
		return previous_playback_position + $end_timer.wait_time - $end_timer.time_left


func set_song(filename):
	# https://github.com/godotengine/godot/issues/17748
	var ogg_file = File.new()
	ogg_file.open(filename, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var ogg_stream = AudioStreamOGGVorbis.new()
	ogg_stream.data = bytes
	stream = ogg_stream
	ogg_file.close()


func _on_start_timer_timeout():
	play()
	started = true


func _on_MusicPlayer_finished():
	$end_timer.start()
	finished = true


func _on_end_timer_timeout():
	completed = true
