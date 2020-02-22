extends Node2D


var HEADER_CHUNK_ID = 0x4D546864
var TRACK_CHUNK_ID = 0x4D54726B

var NOTE_OFF_EVENT = 0x8
var NOTE_ON_EVENT = 0x9
var NOTE_AFTERTOUCH_EVENT = 0xA
var CONTROLLER_EVENT = 0xB
var PROGRAM_CHANGE_EVENT = 0xC
var CHANNEL_AFTERTOUCH_EVENT = 0xD
var PITCH_BEND_EVENT = 0xE
var META_EVENT = 0xF

var META_TEMPO_EVENT = 0x51
var META_TIME_OFFSET_EVENT = 0x54
var META_TIME_SIG_EVENT = 0x58

var TICKS_PER_SECOND = 0
var TICKS_PER_BEAT = 1

var NOTE_LANE_MAP = {52: 0, 50: 1, 48: 2, 40: 3, 38: 4, 36: 5, 53: 6, 51: 7, 49: 8, 41: 9, 39: 10, 37: 11, 35: 12, 34: 13}
var HOLD_NOTES = [53, 51, 49, 41, 39, 37, 34]


var note_starts = []
var tempos = []


func _ready():
	pass


func _process(delta):
	pass


func beats_to_secs(beat):
	var secs = 0
	for i in range(tempos.size()):
		if i < tempos.size()-1 and beat > tempos[i+1][1]:
			secs += ((tempos[i+1][1] - tempos[i][1])/tempos[i][0]) * 60
		else:
			secs += ((beat - tempos[i][1])/tempos[i][0]) * 60
			break


	return secs


func parse_file(filename):
	var file = File.new()
	file.open(filename, File.READ)
	file.set_endian_swap(true)

	# Header Chunk
	var header_chunk_size = parse_chunk_id_and_length(file, HEADER_CHUNK_ID)
	if header_chunk_size != 6:
		print("MIDI HEADER CHUNK SIZE MISMATCH! Expected {0} got {1}".format([6, header_chunk_size]))
		return
	var file_type = file.get_16()
	if file_type != 0 and file_type != 1:
		print("UNSUPPORTED MIDI FILE TYPE " + str(file_type))
		return
	var track_count = file.get_16()
	var time_division_upper = file.get_8()
	var time_division_lower = file.get_8()
	var time_division_mode
	var frames_per_second
	var ticks_per_frame
	var ticks_per_beat
	if time_division_upper > 127:
		# frames per second
		frames_per_second = time_division_upper - 128
		ticks_per_frame = time_division_lower
		time_division_mode = TICKS_PER_SECOND
	else:
		# ticks per beat
		ticks_per_beat = time_division_upper * 256 + time_division_lower
		time_division_mode = TICKS_PER_BEAT

	# Track Chunk
	var track_chunk_length = parse_chunk_id_and_length(file, TRACK_CHUNK_ID)

	var event_type
	var event_channel
	var event_param_1
	var current_beat = 0.0
	var hold_note_starts = {53: 0, 51: 0, 49: 0, 41: 0, 39: 0, 37: 0, 34: 0}
	while file.get_position() < file.get_len():
		var event_delta_time = float(parse_variable_length(file))
		match time_division_mode:
			TICKS_PER_SECOND:
				current_beat += (event_delta_time / ticks_per_frame) / frames_per_second
			TICKS_PER_BEAT:
				current_beat += event_delta_time / ticks_per_beat


		var split_byte = file.get_8()
		if split_byte >= 0x80:
			event_type = split_byte / 16
			event_channel = split_byte % 16
			event_param_1 = file.get_8()
		else:
			event_param_1 = split_byte
		match event_type:
			NOTE_OFF_EVENT:
				var note_number = event_param_1
				var velocity = file.get_8()
				if HOLD_NOTES.has(note_number):
					note_starts.append([NOTE_LANE_MAP[note_number], hold_note_starts[note_number], current_beat])
			NOTE_ON_EVENT:
				var note_number = event_param_1
				var velocity = file.get_8()
				if HOLD_NOTES.has(note_number):
					hold_note_starts[note_number] = current_beat
				else:
					note_starts.append([NOTE_LANE_MAP[note_number], current_beat, 0])
			NOTE_AFTERTOUCH_EVENT:
				var note_number = event_param_1
				var aftertouch_value = file.get_8()
			CONTROLLER_EVENT:
				var controller_number = event_param_1
				var controller_value = file.get_8()
			PROGRAM_CHANGE_EVENT:
				var program_number = event_param_1
				var _unused = file.get_8()
			CHANNEL_AFTERTOUCH_EVENT:
				var aftertouch_value = event_param_1
				var _unused = file.get_8()
			PITCH_BEND_EVENT:
				var pitch_bend_lower = event_param_1
				var pitch_bend_upper = file.get_8()
				var pitch_bend_value = pitch_bend_upper * 256 + pitch_bend_lower
			META_EVENT:
				var meta_event_type = event_param_1
				var meta_event_length = parse_variable_length(file)
				match meta_event_type:
					META_TEMPO_EVENT:
						if meta_event_length != 3:
							print("PANIC " + str(meta_event_length))
						var us_per_quarter = 0
						for i in range(3):
							us_per_quarter *= 256
							us_per_quarter += file.get_8()
						var tempo = 60.0 * 1000 * 1000 / us_per_quarter
						tempos.append([tempo, current_beat])
					META_TIME_SIG_EVENT:
						continue
					_:
						for i in range(meta_event_length):
							var meta_event_byte = file.get_8()
				print("META EVENT %x" % meta_event_type)
			_:
				print("UNRECOGNIZED EVENT TYPE %x" % event_type)


func parse_chunk_id_and_length(file, chunk_id):
	var file_chunk_id = file.get_32()
	if file_chunk_id != chunk_id:
		print("MIDI HEADER CHUNK ID MISMATCH! Expected {0} got {1}".format(["%x" % chunk_id, "%x" % file_chunk_id]))
		return
	return file.get_32()


func parse_variable_length(file):
	var val = 0x80
	var total = 0
	while val >= 0x80:
		val = file.get_8()
		total *= 128
		total += val % 0x80
	return total