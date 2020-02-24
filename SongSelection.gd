extends Node2D

func _ready():
	set_mode("normal")


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

func set_score_normal(text):
	$ScoreNormal.text = text

func set_percent_normal(text):
	$PercentNormal.text = text

func set_streak_normal(text):
	$StreakNormal.text = text

func set_score_advanced(text):
	$ScoreAdvanced.text = text

func set_percent_advanced(text):
	$PercentAdvanced.text = text

func set_streak_advanced(text):
	$StreakAdvanced.text = text

func set_mode(mode):
	if mode == "normal":
		$ScoreNormal.visible = true
		$PercentNormal.visible = true
		$StreakNormal.visible = true
		$ScoreAdvanced.visible = false
		$PercentAdvanced.visible = false
		$StreakAdvanced.visible = false
	elif mode == "advanced":
		$ScoreNormal.visible = false
		$PercentNormal.visible = false
		$StreakNormal.visible = false
		$ScoreAdvanced.visible = true
		$PercentAdvanced.visible = true
		$StreakAdvanced.visible = true
