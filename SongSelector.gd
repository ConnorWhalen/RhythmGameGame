extends Node2D


enum SongFileItem {
	OGG_FILE
	MIDI_FILE
	SONG_TITLE
	SONG_ARTIST
	SONG_YEAR
	TRACK_AUTHOR
	DURATION
}


onready var song_selection_scene = preload("res://SongSelection.tscn")

var SONGS_DIRECTORY = "res://songs/"

var SONG_SELECTION_HEIGHT = 90
var SONGS_PER_SCREEN = 5

var current_selection
var song_files
var song_selections = []

var current_height = 0


func _ready():
	pass


func get_selected_ogg_and_midi():
	var selection = song_files[current_selection]
	return [selection[SongFileItem.OGG_FILE], selection[SongFileItem.MIDI_FILE]]


func reset():
	current_selection = 0
	parse_song_files()

	for song_selection in song_selections:
		remove_child(song_selection)
	song_selections = []

	for song_file in song_files:
		create_song_selection(song_file)

	$Arrow.position.x = -50
	$Arrow.position.y = SONG_SELECTION_HEIGHT/2


func up():
	if current_selection > 0:
		current_selection -= 1

		if current_selection < current_height:
			current_height -= 1
			for song_selection in song_selections:
				song_selection.position.y += SONG_SELECTION_HEIGHT
		else:
			$Arrow.position.y -= SONG_SELECTION_HEIGHT


func down():
	if current_selection < song_selections.size()-1:
		current_selection += 1

		if current_selection >= current_height+SONGS_PER_SCREEN:
			current_height += 1
			for song_selection in song_selections:
				song_selection.position.y -= SONG_SELECTION_HEIGHT
		else:
			$Arrow.position.y += SONG_SELECTION_HEIGHT


func parse_song_files():
	song_files = []
	var file_names = []
	var dir = Directory.new()
	dir.open(SONGS_DIRECTORY)
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".song"):
			file_names.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	for song_file_name in file_names:
		var file = File.new()
		file.open(SONGS_DIRECTORY + song_file_name, File.READ)
		var song_file = {}
		song_file[SongFileItem.OGG_FILE] = SONGS_DIRECTORY + file.get_line()
		song_file[SongFileItem.MIDI_FILE] = SONGS_DIRECTORY + file.get_line()
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
	song_selection.set_author(song_file[SongFileItem.TRACK_AUTHOR])
	song_selection.set_duration(song_file[SongFileItem.DURATION])
	song_selection.position.y = song_selections.size() * SONG_SELECTION_HEIGHT
	song_selections.append(song_selection)
