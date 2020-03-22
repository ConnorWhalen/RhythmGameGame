extends Node2D

func _ready():
	set_mode("easy")


func set_title(text):
	$Title.text = text


func set_artist(text):
	$Artist.text = text


func set_year(text):
	$Year.text = text


func set_author(text):
	$Author.text = text


func set_duration(text):
	$Duration.text = text

func set_record_easy(score, percent, streak):
	$ScoreEasy.text = score
	$PercentEasy.text = percent
	$StreakEasy.text = streak

func set_record_medium(score, percent, streak):
	$ScoreMedium.text = score
	$PercentMedium.text = percent
	$StreakMedium.text = streak

func set_record_expert(score, percent, streak):
	$ScoreExpert.text = score
	$PercentExpert.text = percent
	$StreakExpert.text = streak

func set_record_expertplus(score, percent, streak):
	$ScoreExpertPlus.text = score
	$PercentExpertPlus.text = percent
	$StreakExpertPlus.text = streak

func set_mode(mode):
	$ScoreEasy.visible = false
	$PercentEasy.visible = false
	$StreakEasy.visible = false
	$ScoreMedium.visible = false
	$PercentMedium.visible = false
	$StreakMedium.visible = false
	$ScoreExpert.visible = false
	$PercentExpert.visible = false
	$StreakExpert.visible = false
	$ScoreExpertPlus.visible = false
	$PercentExpertPlus.visible = false
	$StreakExpertPlus.visible = false
	if mode == "easy":
		$ScoreEasy.visible = true
		$PercentEasy.visible = true
		$StreakEasy.visible = true
	elif mode == "medium":
		$ScoreMedium.visible = true
		$PercentMedium.visible = true
		$StreakMedium.visible = true
	elif mode == "expert":
		$ScoreExpert.visible = true
		$PercentExpert.visible = true
		$StreakExpert.visible = true
	elif mode == "expertplus":
		$ScoreExpertPlus.visible = true
		$PercentExpertPlus.visible = true
		$StreakExpertPlus.visible = true
