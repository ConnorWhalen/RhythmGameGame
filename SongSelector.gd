extends Node2D


enum SongFileItem {
	SONG_FILE
	OGG_FILE
	NORMAL_MIDI_FILE
	ADVANCED_MIDI_FILE
	SONG_TITLE
	SONG_ARTIST
	SONG_YEAR
	TRACK_AUTHOR
	DURATION
}


onready var song_selection_scene = preload("res://SongSelection.tscn")

var SONGS_DIRECTORY = "songs/"
var SAVE_FILE_NAME = "user://save_file_2.save"

var SONG_SELECTION_HEIGHT = 90
var SONG_SELECTION_OFFSET = 30
var SONGS_PER_SCREEN = 5

var NORMAL_ROTATION = 180
var ADVANCED_ROTATION = 0

var current_selection
var current_mode = "normal"
var song_files
var song_selections = []
var records

var current_height = 0


func _ready():
	left()


func get_stage_data():
	var selection = song_files[current_selection]
	if current_mode == "normal":
		return [selection[SongFileItem.OGG_FILE], selection[SongFileItem.NORMAL_MIDI_FILE], selection[SongFileItem.SONG_FILE], current_mode]
	else:
		return [selection[SongFileItem.OGG_FILE], selection[SongFileItem.ADVANCED_MIDI_FILE], selection[SongFileItem.SONG_FILE], current_mode]


func reset():
	current_selection = 0
	parse_song_files()

	for song_selection in song_selections:
		remove_child(song_selection)
	song_selections = []

	var save_file = File.new()
	save_file.open(SAVE_FILE_NAME, File.READ)
	var save_object = save_file.get_var()
	if save_object:
		records = save_object.get("records")
	if not records:
		records = []
	save_file.close()

	for song_file in song_files:
		create_song_selection(song_file)

	$SongArrow.position.x = -50
	$SongArrow.position.y = SONG_SELECTION_OFFSET + SONG_SELECTION_HEIGHT/2



func left():
	current_mode = "normal"
	$ModeArrow.rotation_degrees = NORMAL_ROTATION
	for selection in song_selections:
		selection.set_mode("normal")



func right():
	current_mode = "advanced"
	$ModeArrow.rotation_degrees = ADVANCED_ROTATION
	for selection in song_selections:
		selection.set_mode("advanced")


func up():
	if current_selection > 0:
		current_selection -= 1

		if current_selection < current_height:
			current_height -= 1
			for song_selection in song_selections:
				song_selection.position.y += SONG_SELECTION_HEIGHT
		else:
			$SongArrow.position.y -= SONG_SELECTION_HEIGHT


func down():
	if current_selection < song_selections.size()-1:
		current_selection += 1

		if current_selection >= current_height+SONGS_PER_SCREEN:
			current_height += 1
			for song_selection in song_selections:
				song_selection.position.y -= SONG_SELECTION_HEIGHT
		else:
			$SongArrow.position.y += SONG_SELECTION_HEIGHT


func search_dir(dir_name):
	var file_names = []
	var dir = Directory.new()
	dir.open(SONGS_DIRECTORY + dir_name)
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".song"):
			file_names.append(file_name)
		file_name = dir.get_next()
	return file_names


func parse_song_files():
	song_files = []
	var file_names = []
	var dir = Directory.new()
	dir.open(SONGS_DIRECTORY)
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".song"):
				file_names.append(["", file_name])
		else:
			var dir_files = search_dir(file_name)
			for dir_file in dir_files:
				file_names.append([file_name, dir_file])
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
		song_file_path = song_file_name
		if song_file_dir != "":
			song_file_path = song_file_dir + "/" + song_file_name
		file = File.new()
		file.open(SONGS_DIRECTORY + song_file_path, File.READ)
		version = file.get_line()
		if version != "1":
			print("Incompatible  song file version %s!" % version)
		song_file = {}
		song_file[SongFileItem.SONG_FILE] = song_file_name
		song_file[SongFileItem.OGG_FILE] = SONGS_DIRECTORY + song_file_dir + "/" + file.get_line()
		song_file[SongFileItem.NORMAL_MIDI_FILE] = SONGS_DIRECTORY + song_file_dir + "/" + file.get_line()
		song_file[SongFileItem.ADVANCED_MIDI_FILE] = SONGS_DIRECTORY + song_file_dir + "/" + file.get_line()
		song_file[SongFileItem.SONG_TITLE] = file.get_line()
		song_file[SongFileItem.SONG_ARTIST] = file.get_line()
		song_file[SongFileItem.SONG_YEAR] = file.get_line()
		song_file[SongFileItem.TRACK_AUTHOR] = file.get_line()
		song_file[SongFileItem.DURATION] = file.get_line()
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

	song_selection.set_score_normal("")
	song_selection.set_percent_normal("")
	song_selection.set_streak_normal("")
	song_selection.set_score_advanced("")
	song_selection.set_percent_advanced("")
	song_selection.set_streak_advanced("")
	for record in records:
		if record["song_file_name"] == song_file[SongFileItem.SONG_FILE]: 
			if record["mode"] == "normal":
				song_selection.set_score_normal("Best " + str(record["score"]))
				song_selection.set_percent_normal(record["percent"])
				song_selection.set_streak_normal("Streak " + str(record["streak"]))
			elif record["mode"] == "advanced":
				song_selection.set_score_advanced("Best " + str(record["score"]))
				song_selection.set_percent_advanced(record["percent"])
				song_selection.set_streak_advanced("Streak " + str(record["streak"]))

	song_selections.append(song_selection)
