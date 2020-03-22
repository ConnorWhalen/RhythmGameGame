extends AudioStreamPlayer

var FADE_SPEED = 40 # dB/s

var fade_in = false
var fade_out = false
var start_position = 0
var end_position = 30
var fade_out_start = 26


func _ready():
	pass


func reset(filename, position):
	if filename == "" and position == "":
		if playing:
			stop()
		return

	# https://github.com/godotengine/godot/issues/17748
	var ogg_file = File.new()
	ogg_file.open(filename, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var ogg_stream = AudioStreamOGGVorbis.new()
	ogg_stream.data = bytes
	stream = ogg_stream
	ogg_file.close()

	volume_db = -40
	play(position)
	fade_in = true

	start_position = position
	end_position = start_position + 30
	fade_out_start = end_position - 1


func off():
	if playing:
		stop()


func _process(delta):
	if playing:
		var position = get_playback_position()
		if position >= end_position:
			fade_out = false
			volume_db = -40
			seek(start_position)
			fade_in = true
		elif position >= fade_out_start:
			fade_out = true

		if fade_in:
			volume_db += delta * FADE_SPEED
			if volume_db > 0:
				volume_db = 0
				fade_in = false
		elif fade_out:
			volume_db -= delta * FADE_SPEED


