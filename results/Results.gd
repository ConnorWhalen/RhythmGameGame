extends Node2D

signal mode_stage
signal mode_menu
signal mode_results

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

	var percent = make_single_decimal((float(green_count) + 0.5 * float(yellow_count))/ float(gem_count))

	$NewRecordText.visible = Save.store_record(song_file_name, song_mode, score, best_streak, percent)


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
