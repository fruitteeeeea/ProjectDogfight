extends "res://tests/integration/test_mission_select.gd"

var sounds: Node

func sound_count() -> int:
	return sounds.get("click_count")

func menu_button(text: String) -> Button:
	for button in manager._pause_panel.find_children("*", "Button", true, false):
		if button.text == text:
			return button
	return null

func key_pause(echo: bool = false, joy: bool = false) -> void:
	var event: InputEvent
	if joy:
		event = InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_START
	else:
		event = InputEventKey.new()
		event.keycode = KEY_ESCAPE
		event.echo = echo
	event.pressed = true
	get_viewport().push_input(event, true)
	await frames()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await frames()
	sounds = SoundManager
	sounds.set_script(load("res://tests/integration/ui_click_sound_spy.gd"))
	sounds.set("sfx", sounds.get_node("SFX"))
	var audio: AudioStreamPlayer = sounds.get_node("UIClick")
	var sound_configuration: Node = load("res://game/autoload/sound_manager.tscn").instantiate()
	var configured_volume: float = sound_configuration.get_node("UIClick").volume_db
	sound_configuration.free()
	expect(audio.stream.resource_path == "res://assets/audio/ui/mouseclick1.ogg" and audio.bus == &"SFX" and audio.max_polyphony == 4 and audio.volume_db == configured_volume and audio.pitch_scale == 1.0, "preplaced click player uses requested stream and defaults")
	expect(sounds.process_mode == Node.PROCESS_MODE_ALWAYS, "sound manager always processes")
	var title := await open_scene(TITLE)
	await pointer(Vector2(800, 700), true)
	expect(sound_count() == 0, "title before animation is silent")
	title.get_node("AnimationPlayer").advance(2.1)
	await frames()
	await pointer(Vector2(800, 700), true)
	await frames(5)
	expect(sound_count() == 1 and get_tree().current_scene.scene_file_path == SELECTOR, "title touch plays exactly once")
	var selector: Control = get_tree().current_scene
	var row: HBoxContainer = selector.get_node("%MissionButtons")
	await action(&"ui_right")
	expect(sound_count() == 1, "focus selection is silent")
	await action(&"ui_accept")
	expect(sound_count() == 2, "confirm already-selected mission plays once")
	await click(row.get_child(0))
	expect(sound_count() == 3, "mouse mission selection plays once")
	await click(row.get_child(0))
	expect(sound_count() == 4, "mouse already-selected mission plays once")
	await pointer(row.get_child(2).get_global_rect().get_center(), true)
	expect(sound_count() == 5, "raw touch mission selection plays once despite focus change")
	await pointer(row.get_child(3).get_global_rect().get_center(), true)
	await pointer(Vector2(20, 20), true)
	expect(sound_count() == 5, "locked and blank touches are silent")
	var down := InputEventScreenTouch.new()
	down.pressed = true
	down.position = row.get_child(1).get_global_rect().get_center()
	get_viewport().push_input(down, true)
	var canceled := InputEventScreenTouch.new()
	canceled.position = down.position
	canceled.canceled = true
	get_viewport().push_input(canceled, true)
	await frames()
	expect(sound_count() == 5, "canceled touch is silent")
	selector._request_start()
	selector._request_start()
	await frames(5)
	expect(sound_count() == 6, "duplicate start request plays once")
	expect(sounds == SoundManager and audio.get_parent() == sounds, "scene switch preserves global audio player")
	game = get_tree().current_scene
	manager = game.get_node("GameManager")
	manager._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await frames()
	expect(sound_count() == 6 and manager.state == GameStatusServer.BattleState.PAUSED, "automatic focus pause is silent")
	await get_tree().create_timer(1.1, true, false, true).timeout
	expect(audio.bus == &"SFX" and not audio.stream_paused and audio.can_process() and not AudioServer.is_bus_mute(AudioServer.get_bus_index(audio.bus)), "pause mute leaves click player available")
	await pointer(menu_button("Continue").get_global_rect().get_center(), true)
	expect(sound_count() == 7 and manager.state == GameStatusServer.BattleState.FREE_FLIGHT, "touch Continue plays once")
	await key_pause()
	expect(sound_count() == 8 and manager.state == GameStatusServer.BattleState.PAUSED, "keyboard pause plays once")
	await key_pause(true)
	expect(sound_count() == 8, "keyboard echo is silent")
	await key_pause(false, true)
	expect(sound_count() == 9 and manager.state == GameStatusServer.BattleState.FREE_FLIGHT, "controller resume plays once")
	await click(manager._pause_button)
	expect(sound_count() == 10 and manager.state == GameStatusServer.BattleState.PAUSED, "mouse pause is not double-played by GUI")
	await click(menu_button("Retry"))
	await frames(5)
	expect(sound_count() == 11 and get_tree().current_scene.get_node("GameManager").state == GameStatusServer.BattleState.FREE_FLIGHT, "pause Retry plays once across reload")
	game = get_tree().current_scene
	manager = game.get_node("GameManager")
	await pointer(manager.ready_to_start.get_node("PanelContainer").get_global_rect().get_center(), true)
	expect(sound_count() == 12 and GameStatusServer.is_battle_active(), "challenge prompt plays once")
	manager.finish_battle(manager.EndReason.TIME_UP)
	await frames()
	await pointer(Vector2(800, 700), true)
	expect(sound_count() == 12, "early result click is silent")
	await get_tree().create_timer(2.2, true, false, true).timeout
	expect(audio.bus == &"SFX" and not audio.stream_paused and not AudioServer.is_bus_mute(AudioServer.get_bus_index(audio.bus)), "result mute leaves UI click bus available")
	await pointer(Vector2(800, 700), true)
	await frames(5)
	expect(sound_count() == 13 and get_tree().current_scene.scene_file_path == SELECTOR, "result touch plays once and returns to selection")
	selector = get_tree().current_scene
	await pointer(selector.get_node("%StartMission").get_global_rect().get_center(), true)
	await frames(5)
	expect(sound_count() == 14, "touch Start plays once")
	game = get_tree().current_scene
	manager = game.get_node("GameManager")
	await click(manager._pause_button)
	await click(menu_button("Select mission"))
	await frames(5)
	expect(sound_count() == 16 and get_tree().current_scene.scene_file_path == SELECTOR, "pause Select mission plays once")
	# Alternate pointer/confirmation paths must share the same single-play rules.
	title = await open_scene(TITLE)
	title.get_node("AnimationPlayer").advance(2.1)
	await frames()
	await pointer(Vector2(800, 700))
	await frames(5)
	expect(sound_count() == 17, "mouse title click plays once")
	await action(&"ui_down")
	await action(&"ui_accept")
	await frames(5)
	expect(sound_count() == 18, "focused Start confirmation plays once")
	game = get_tree().current_scene
	manager = game.get_node("GameManager")
	await pointer(Vector2(20, 20), true)
	expect(sound_count() == 18, "trial blank and combat touch add no UI sound")
	await action(&"start_game")
	expect(sound_count() == 19 and GameStatusServer.is_battle_active(), "challenge confirmation plays once")
	manager.finish_battle(manager.EndReason.TIME_UP)
	await frames()
	await get_tree().create_timer(2.2, true, false, true).timeout
	await action(&"start_game")
	await frames(5)
	expect(sound_count() == 20 and get_tree().current_scene.scene_file_path == SELECTOR, "result confirmation plays once")
	get_tree().current_scene.queue_free()
	await get_tree().create_timer(5.5, true, false, true).timeout
	print("UI click sound tests: %d failure(s)" % failures)
	get_tree().quit(1 if failures else 0)
