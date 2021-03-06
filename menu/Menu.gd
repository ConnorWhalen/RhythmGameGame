extends Node2D

enum State {
	ENTER,
	MAIN_MENU,
	SETTINGS_MENU,
	SONG_MENU
}

enum Option {
	HOWTO,
	PLAYSONG,
	SETTINGS,
	OPTION_COUNT
}

signal mode_stage
signal mode_menu
signal mode_results
signal mode_settings

var current_state
var current_selection

var debounce = false
var debounce_up = false
var debounce_down = false
var debounce_left = false
var debounce_right = false
var debounce_plus = false
var debounce_minus = false


func _ready():
	current_state = State.ENTER


func _process(delta):
	if debounce and not Input.is_action_pressed("ui_accept"):
		debounce = false
	if debounce_up and not Input.is_action_pressed("ui_up"):
		debounce_up = false
	if debounce_down and not Input.is_action_pressed("ui_down"):
		debounce_down = false
	if debounce_left and not Input.is_action_pressed("ui_left"):
		debounce_left = false
	if debounce_right and not Input.is_action_pressed("ui_right"):
		debounce_right = false
	if debounce_plus and not Input.is_action_pressed("plus"):
		debounce_plus = false
	if debounce_minus and not Input.is_action_pressed("minus"):
		debounce_minus = false
	match current_state:
		State.ENTER:
			if Input.is_action_pressed("ui_accept"):
				set_state(State.MAIN_MENU)
				debounce = true
		State.MAIN_MENU:
			if not debounce_left and Input.is_action_pressed("ui_left"):
				if current_selection > 0:
					current_selection -= 1
				else:
					current_selection = Option.OPTION_COUNT - 1
				$Arrow.set_state(current_selection)
				debounce_left = true
			elif not debounce_right and Input.is_action_pressed("ui_right"):
				if current_selection < Option.OPTION_COUNT:
					current_selection += 1
				else:
					current_selection = 0
				$Arrow.set_state(current_selection)
				debounce_right = true
			elif not debounce and Input.is_action_pressed("ui_accept"):
				match current_selection:
					Option.PLAYSONG:
						set_state(State.SONG_MENU)
					Option.HOWTO:
						set_state(State.SETTINGS_MENU)
					Option.SETTINGS:
						emit_signal("mode_settings")
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
			if not debounce_left and Input.is_action_pressed("ui_left"):
				$SongSelector.left()
				debounce_left = true
			elif not debounce_right and Input.is_action_pressed("ui_right"):
				$SongSelector.right()
				debounce_right = true
			if not debounce_plus and Input.is_action_pressed("plus"):
				$SongSelector.plus()
				debounce_plus = true
			elif not debounce_minus and Input.is_action_pressed("minus"):
				$SongSelector.minus()
				debounce_minus = true
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
			$SettingsText2.visible = false
			$Arrow.visible = false
			$TitleBG.visible = false
		State.SETTINGS_MENU:
			$InputMap.visible = false
			$SettingsBG.visible = false
			$SettingsControlsText.visible = false
			$SettingsDescription.visible = false
		State.SONG_MENU:
			$SongSelector.visible = false
			$SongSelector.off()
			$MenuMusic.playing = true

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
			$SettingsText2.visible = true
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
			$SongSelector.visible = true
			$SongSelector.reset()
			$MenuMusic.playing = false
