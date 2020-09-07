extends Node

var SAVE_FILE_NAME = "user://save_file_2.save"

var NOTE_SPEED = "note_speed"
var NOTE_SPEED_MAX = 4.0
var NOTE_SPEED_MIN = 1.0

var _settings
var _records

func _ready():
	pull_save()


func get_records():
	return _records


func store_record(song_file_name, song_mode, score, best_streak, percent):
	var new_record = false
	var record_found = false

	for record in _records:
		if record["song_file_name"] == song_file_name and record["mode"] == song_mode:
			if score > record["score"]:
				record["score"] = score
				record["streak"] = best_streak
				record["percent"] = percent
				new_record = true
			record_found = true
	if not record_found:
		var new_result = {"song_file_name": song_file_name, "mode": song_mode, "score": score, "streak": best_streak, "percent": percent}
		_records.append(new_result)
		new_record = true

	push_save()

	return new_record


func get_setting(name):
	var default = null
	if name == NOTE_SPEED:
		default = 1.0
	return _settings.get(name, default)


func store_setting(name, value):
	_settings[name] = value
	push_save()


func pull_save():
	var save_file = File.new()
	save_file.open(SAVE_FILE_NAME, File.READ)
	var save_object = save_file.get_var()

	# pull records
	_records = null
	if save_object:
		_records = save_object.get("records")
	if not _records:
		_records = []
	else:
		for record in _records:
			if record["mode"] == "normal":
				record["mode"] = "expert"
			if record["mode"] == "advanced":
				record["mode"] = "expertplus"

	# pull settings
	_settings = null
	if save_object:
		_settings = save_object.get("settings")
	if not _settings:
		_settings = {}

	save_file.close()


func push_save():
	var save_file = File.new()
	save_file.open(SAVE_FILE_NAME, File.WRITE)
	save_file.store_var({"records": _records, "settings": _settings})
	save_file.close()
