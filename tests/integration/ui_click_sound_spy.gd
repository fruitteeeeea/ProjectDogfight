extends "res://game/autoload/sound_manager.gd"

var click_count := 0

func play_ui_click() -> void:
	click_count += 1
	super.play_ui_click()
