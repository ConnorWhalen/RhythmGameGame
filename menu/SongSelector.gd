extends Node2D


enum SongFileItem {
	SONG_FILE
	OGG_FILE
	EASY_MIDI_FILE
	MEDIUM_MIDI_FILE
	EXPERT_MIDI_FILE
	EXPERTPLUS_MIDI_FILE
	SONG_TITLE
	SONG_ARTIST
	SONG_YEAR
	TRACK_AUTHOR
	DURATION
	SAMPLE_START
}

enum Mode {
	EASY
	MEDIUM
	EXPERT
	EXPERT_PLUS
}


onready var song_selection_scene = preload("res://menu/SongSelection.tscn")

var SONGS_DIRECTORY = "songs/"

var SONG_SELECTION_HEIGHT = 90
var SONG_SELECTION_OFFSET = 30
var SONGS_PER_SCREEN = 5

var MODE_ARROW_GAP = 35

var current_selection
var current_mode = Mode.EASY
var song_files
var song_selections = []
var records
var note_speed

var current_height


func _ready():
	left()


func get_stage_data():
	var selection = song_files[current_selection]
	var midi_file
	match current_mode:
		Mode.EASY:
			midi_file = selection[SongFileItem.EASY_MIDI_FILE]
		Mode.MEDIUM:
			midi_file = selection[SongFileItem.MEDIUM_MIDI_FILE]
		Mode.EXPERT:
			midi_file = selection[SongFileItem.EXPERT_MIDI_FILE]
		Mode.EXPERT_PLUS:
			midi_file = selection[SongFileItem.EXPERTPLUS_MIDI_FILE]
	return [selection[SongFileItem.OGG_FILE], midi_file, selection[SongFileItem.SONG_FILE], mode_to_string(current_mode)]


func reset():
	$SongArrow.visible = true
	$FolderNotFound.visible = false
	current_selection = 0
	current_height = 0
	parse_song_files()

	for song_selection in song_selections:
		remove_child(song_selection)
	song_selections = []

	records = Save.get_records()

	for song_file in song_files:
		create_song_selection(song_file)

	$SongArrow.position.x = -50
	$SongArrow.position.y = SONG_SELECTION_OFFSET + SONG_SELECTION_HEIGHT/2

	note_speed = Save.get_setting(Save.NOTE_SPEED)
	set_note_speed()

	set_sampler()


func off():
	$SongSampler.off()



func left():
	if current_mode > Mode.EASY:
		current_mode -= 1
		set_mode()
		$ModeArrow.position.y -= MODE_ARROW_GAP


func right():
	if current_mode < Mode.EXPERT_PLUS:
		current_mode += 1
		set_mode()
		$ModeArrow.position.y += MODE_ARROW_GAP


func up():
	if current_selection > 0:
		current_selection -= 1
		set_sampler()

		if current_selection < current_height:
			current_height -= 1
			for song_selection in song_selections:
				song_selection.position.y += SONG_SELECTION_HEIGHT
		else:
			$SongArrow.position.y -= SONG_SELECTION_HEIGHT


func down():
	if current_selection < song_selections.size()-1:
		current_selection += 1
		set_sampler()

		if current_selection >= current_height+SONGS_PER_SCREEN:
			current_height += 1
			for song_selection in song_selections:
				song_selection.position.y -= SONG_SELECTION_HEIGHT
		else:
			$SongArrow.position.y += SONG_SELECTION_HEIGHT


func plus():
	if note_speed < Save.NOTE_SPEED_MAX:
		note_speed += 0.1
	set_note_speed()


func minus():
	if note_speed > Save.NOTE_SPEED_MIN:
		note_speed -= 0.1
	set_note_speed()


func set_mode():
	for selection in song_selections:
		selection.set_mode(mode_to_string(current_mode))
	$EasyBG.visible = false
	$MediumBG.visible = false
	$ExpertBG.visible = false
	$ExpertPlusBG.visible = false
	match current_mode:
		Mode.EASY:
			$EasyBG.visible = true
		Mode.MEDIUM:
			$MediumBG.visible = true
		Mode.EXPERT:
			$ExpertBG.visible = true
		Mode.EXPERT_PLUS:
			$ExpertPlusBG.visible = true


func set_note_speed():
	$NoteSpeedText.text = "Speed: " + ("%.1f" % note_speed)
	Save.store_setting(Save.NOTE_SPEED, note_speed)


func set_sampler():
	if song_files.size() > current_selection:
		var filename = song_files[current_selection][SongFileItem.OGG_FILE]
		var sample_start = song_files[current_selection][SongFileItem.SAMPLE_START]
		$SongSampler.reset(filename, sample_start)


func search_dir(dir_name):
	var file_names = []
	var dir = Directory.new()
	var code = dir.open(dir_name)
	if code != 0:
		print("FOLDER %s OPEN RETURN CODE: %s", dir_name, str(code))
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".song"):
				file_names.append([dir_name, file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(dir_name + "/" + file_name)
		file_name = dir.get_next()
	return file_names


func parse_song_files():
	song_files = []
	var file_names = []
	var dir = Directory.new()

	var code = dir.open(SONGS_DIRECTORY)
	print("OPEN RETURN CODE: " + str(code))

	if code == ERR_INVALID_PARAMETER:
		$SongArrow.visible = false
		$FolderNotFound.visible = true
		return

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".song"):
				file_names.append(["", file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(SONGS_DIRECTORY + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	var song_file_name
	var song_file_dir
	var song_file_path

	var file
	var version
	var song_file
	for file_name_entry in file_names:
		song_file_dir = file_name_entry[0]
		song_file_name = file_name_entry[1]
		print(song_file_dir + " " + song_file_name)
		song_file_path = song_file_name
		if song_file_dir != "":
			song_file_path = song_file_dir + "/" + song_file_name
		file = File.new()
		file.open(song_file_path, File.READ)
		version = file.get_line()
		song_file = {}
		if version != "3":
			print("Incompatible  song file version %s!" % version)
			song_file[SongFileItem.SONG_FILE] = song_file_name
			song_file[SongFileItem.SONG_TITLE] = song_file_name
			song_file[SongFileItem.SONG_ARTIST] = "Bad Version (%s)" % version

			song_file[SongFileItem.OGG_FILE] = ""
			song_file[SongFileItem.EASY_MIDI_FILE] = ""
			song_file[SongFileItem.MEDIUM_MIDI_FILE] = ""
			song_file[SongFileItem.EXPERT_MIDI_FILE] = ""
			song_file[SongFileItem.EXPERTPLUS_MIDI_FILE] = ""
			song_file[SongFileItem.SONG_YEAR] = ""
			song_file[SongFileItem.TRACK_AUTHOR] = ""
			song_file[SongFileItem.DURATION] = ""
			song_file[SongFileItem.SAMPLE_START] = ""
		else:
			song_file[SongFileItem.SONG_FILE] = song_file_name
			song_file[SongFileItem.OGG_FILE] = song_file_dir + "/" + file.get_line()
			song_file[SongFileItem.EASY_MIDI_FILE] = song_file_dir + "/" + file.get_line()
			song_file[SongFileItem.MEDIUM_MIDI_FILE] = song_file_dir + "/" + file.get_line()
			song_file[SongFileItem.EXPERT_MIDI_FILE] = song_file_dir + "/" + file.get_line()
			song_file[SongFileItem.EXPERTPLUS_MIDI_FILE] = song_file_dir + "/" + file.get_line()
			song_file[SongFileItem.SONG_TITLE] = file.get_line()
			song_file[SongFileItem.SONG_ARTIST] = file.get_line()
			song_file[SongFileItem.SONG_YEAR] = file.get_line()
			song_file[SongFileItem.TRACK_AUTHOR] = file.get_line()
			song_file[SongFileItem.DURATION] = file.get_line()
			var sample_start_str = file.get_line()
			var sample_start = sample_start_str.split(":")
			song_file[SongFileItem.SAMPLE_START] = int(sample_start[0]) * 60 + float(sample_start[1])
		song_files.append(song_file)


func create_song_selection(song_file):
	var song_selection = song_selection_scene.instance()
	add_child(song_selection)
	song_selection.set_title(song_file[SongFileItem.SONG_TITLE])
	song_selection.set_artist(song_file[SongFileItem.SONG_ARTIST])
	song_selection.set_year(song_file[SongFileItem.SONG_YEAR])
	song_selection.set_author("Chart by " + song_file[SongFileItem.TRACK_AUTHOR])
	song_selection.set_duration(song_file[SongFileItem.DURATION])
	song_selection.position.y = song_selections.size() * SONG_SELECTION_HEIGHT + SONG_SELECTION_OFFSET

	song_selection.set_record_easy("", "", "")
	song_selection.set_record_medium("", "", "")
	song_selection.set_record_expert("", "", "")
	song_selection.set_record_expertplus("", "", "")
	for record in records:
		if record["song_file_name"] == song_file[SongFileItem.SONG_FILE]: 
			if record["mode"] == "easy":
				song_selection.set_record_easy("Best " + str(record["score"]), record["percent"], "Streak " + str(record["streak"]))
			elif record["mode"] == "medium":
				song_selection.set_record_medium("Best " + str(record["score"]), record["percent"], "Streak " + str(record["streak"]))
			elif record["mode"] == "expert":
				song_selection.set_record_expert("Best " + str(record["score"]), record["percent"], "Streak " + str(record["streak"]))
			elif record["mode"] == "expertplus":
				song_selection.set_record_expertplus("Best " + str(record["score"]), record["percent"], "Streak " + str(record["streak"]))

	song_selections.append(song_selection)


func mode_to_string(mode):
	match mode:
		Mode.EASY:
			return "easy"
		Mode.MEDIUM:
			return "medium"
		Mode.EXPERT:
			return "expert"
		Mode.EXPERT_PLUS:
			return "expertplus"
