extends Node2D

enum State {
	ENTER,
	MAIN_MENU,
	SETTINGS_MENU
}

enum Option {
	PLAYSONG,
	SETTINGS
}

signal mode_stage
signal mode_menu

var current_state
var current_selection

var debounce = false


func _ready():
	current_state = State.ENTER


func _process(delta):
	if debounce and not Input.is_action_pressed("ui_accept"):
		debounce = false
	match current_state:
		State.ENTER:
			if Input.is_action_pressed("ui_accept"):
				set_state(State.MAIN_MENU)
				debounce = true
		State.MAIN_MENU:
			if Input.is_action_pressed("ui_left"):
				$Arrow.set_state(Option.PLAYSONG)
				current_selection = Option.PLAYSONG
			elif Input.is_action_pressed("ui_right"):
				$Arrow.set_state(Option.SETTINGS)
				current_selection = Option.SETTINGS
			elif not debounce and Input.is_action_pressed("ui_accept"):
				match current_selection:
					Option.PLAYSONG:
						emit_signal("mode_stage")
					Option.SETTINGS:
						set_state(State.SETTINGS_MENU)
						debounce = true
		State.SETTINGS_MENU:
			if not debounce and Input.is_action_pressed("ui_accept"):
				set_state(State.MAIN_MENU)
				debounce = true


func set_state(state):
	# tear down state
	match current_state:
		State.ENTER:
			$PressEnterText.visible = false
			$TitleBG.visible = false
		State.MAIN_MENU:
			$PlaySongText.visible = false
			$SettingsText.visible = false
			$Arrow.visible = false
			$TitleBG.visible = false
		State.SETTINGS_MENU:
			$PressEnterText.visible = false
			$SettingsBG.visible = false

	current_state = state

	# set up state
	match current_state:
		State.ENTER:
			$PressEnterText.visible = true
			$TitleBG.visible = true
		State.MAIN_MENU:
			$PlaySongText.visible = true
			$SettingsText.visible = true
			$Arrow.visible = true
			$TitleBG.visible = true
			current_selection = Option.PLAYSONG
		State.SETTINGS_MENU:
			$PressEnterText.visible = true
			$SettingsBG.visible = true
