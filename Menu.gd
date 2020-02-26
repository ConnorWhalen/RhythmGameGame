extends Node2D

enum State {
	ENTER,
	MAIN_MENU,
	SETTINGS_MENU,
	SONG_MENU
}

enum Option {
	PLAYSONG,
	SETTINGS
}

signal mode_stage
signal mode_menu
signal mode_results

var current_state
var current_selection

var debounce = false
var debounce_up = false
var debounce_down = false


func _ready():
	current_state = State.ENTER


func _process(delta):
	if debounce and not Input.is_action_pressed("ui_accept"):
		debounce = false
	if debounce_up and not Input.is_action_pressed("ui_up"):
		debounce_up = false
	if debounce_down and not Input.is_action_pressed("ui_down"):
		debounce_down = false
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
						set_state(State.SONG_MENU)
						debounce = true
					Option.SETTINGS:
						set_state(State.SETTINGS_MENU)
						debounce = true
		State.SETTINGS_MENU:
			if not debounce and Input.is_action_pressed("ui_accept"):
				set_state(State.MAIN_MENU)
				debounce = true
		State.SONG_MENU:
			if not debounce and Input.is_action_pressed("ui_accept"):
				emit_signal("mode_stage", $SongSelector.get_stage_data())
			if not debounce_up and Input.is_action_pressed("ui_up"):
				$SongSelector.up()
				debounce_up = true
			if not debounce_down and Input.is_action_pressed("ui_down"):
				$SongSelector.down()
				debounce_down = true
			if Input.is_action_pressed("ui_left"):
				$SongSelector.left()
			elif Input.is_action_pressed("ui_right"):
				$SongSelector.right()
			if Input.is_action_pressed("ui_back"):
				set_state(State.MAIN_MENU)


func set_state(state):
	# tear down state
	match current_state:
		State.ENTER:
			$PressEnterText.visible = false
			$TitleBG.visible = false
			$VersionText.visible = false
		State.MAIN_MENU:
			$PlaySongText.visible = false
			$SettingsText.visible = false
			$Arrow.visible = false
			$TitleBG.visible = false
		State.SETTINGS_MENU:
			$InputMap.visible = false
			$SettingsBG.visible = false
			$SettingsControlsText.visible = false
			$SettingsDescription.visible = false
		State.SONG_MENU:
			$ChooseSongBG.visible = false
			$SongSelector.visible = false
			$SongSelectControlsText.visible = false

	current_state = state

	# set up state
	match current_state:
		State.ENTER:
			$PressEnterText.visible = true
			$TitleBG.visible = true
			$VersionText.visible = true
		State.MAIN_MENU:
			$PlaySongText.visible = true
			$SettingsText.visible = true
			$Arrow.visible = true
			$TitleBG.visible = true
			current_selection = Option.PLAYSONG
			$Arrow.set_state(current_selection)
		State.SETTINGS_MENU:
			$InputMap.visible = true
			$SettingsBG.visible = true
			$SettingsControlsText.visible = true
			$SettingsDescription.visible = true
		State.SONG_MENU:
			$ChooseSongBG.visible = true
			$SongSelector.visible = true
			$SongSelectControlsText.visible = true
			$SongSelector.reset()
