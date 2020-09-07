extends Node2D

signal mode_stage
signal mode_menu
signal mode_results

var SAVE_FILE_NAME = "user://save_file_2.save"

var score
var gem_count
var green_count
var yellow_count
var red_count
var best_streak
var song_file_name
var song_mode


func _ready():
	pass


func init(results_data):
	score = results_data[0]
	gem_count = results_data[1]
	green_count = results_data[2]
	yellow_count = results_data[3]
	red_count = results_data[4]
	best_streak = results_data[5]
	song_file_name = results_data[6]
	song_mode = results_data[7]

	var total_percent = (float(green_count) + 0.5 * float(yellow_count))/ float(gem_count)
	$ScoreText.text = str(score)
	$PercentText.text = make_single_decimal(total_percent)
	$GreenText.text = "X " + str(green_count)
	$YellowText.text = "X " + str(yellow_count)
	$RedText.text = "X " + str(red_count)
	$TotalText.text = str(gem_count)
	$GreenPercentText.text = make_single_decimal(float(green_count) / float(gem_count))
	$YellowPercentText.text = make_single_decimal(float(yellow_count) / float(gem_count))
	$RedPercentText.text = make_single_decimal(float(red_count) / float(gem_count))
	$StreakText.text = str(best_streak)
	$RankF.visible = false
	render_rank(total_percent * 100)

	var save_file = File.new()
	save_file.open(SAVE_FILE_NAME, File.READ)
	var save_object = save_file.get_var()
	var records = null
	if save_object:
		records = save_object.get("records")
	var record_found = false
	var percent = make_single_decimal((float(green_count) + 0.5 * float(yellow_count))/ float(gem_count))
	if not records:
		records = []
		var new_record = {"song_file_name": song_file_name, "mode": song_mode, "score": score, "streak": best_streak, "percent": percent}
		records.append(new_record)
	else:
		for record in records:
			if record["mode"] == "normal":
				record["mode"] = "expert"
			if record["mode"] == "advanced":
				record["mode"] = "expertplus"
			if record["song_file_name"] == song_file_name and record["mode"] == song_mode:
				if score > record["score"]:
					record["score"] = score
					record["streak"] = best_streak
					record["percent"] = percent
					$NewRecordText.visible = true
				record_found = true
		if not record_found:
			var new_record = {"song_file_name": song_file_name, "mode": song_mode, "score": score, "streak": best_streak, "percent": percent}
			records.append(new_record)

	save_file.close()
	save_file.open(SAVE_FILE_NAME, File.WRITE)
	save_file.store_var({"records": records})
	save_file.close()


func render_rank(percent):
	$RankF.visible = false
	if percent < 40:
		$RankF.visible = true
	elif percent < 50:
		$RankE.visible = true
	elif percent < 60:
		$RankD.visible = true
	elif percent < 70:
		$RankC.visible = true
	elif percent < 80:
		$RankB.visible = true
	elif percent < 90:
		$RankA.visible = true
	elif percent < 95:
		$RankS.visible = true
	elif percent < 97.5:
		$RankSS.visible = true
	else:
		$RankSSS.visible = true


func make_single_decimal(number):
	return "%.1f%%" % (number * 100)


func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		emit_signal("mode_menu")
