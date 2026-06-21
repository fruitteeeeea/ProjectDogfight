extends Node

var joystick_pressed := false
var observed_events: Array[String] = []


func _input(event: InputEvent) -> void:
	var details := event.get_class()
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		details += " position=%s" % event.position
	observed_events.append(details)


func _ready() -> void:
	var player := (load("res://Unit/Player/player.tscn") as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(player)
	await get_tree().process_frame
	await get_tree().process_frame

	var touch_control := player.get_node("HUD/PlayerTouchControl") as Control
	var joystick := player.get_node("HUD/PlayerTouchControl/MoveJoystick") as VirtualJoystick
	joystick.pressed.connect(func(): joystick_pressed = true)
	await get_tree().process_frame

	GameStatusServer.current_input_mode = GameStatusServer.InputMode.GAMEPAD
	GameStatusServer.current_input_mode = GameStatusServer.InputMode.KEYBOARD
	await get_tree().process_frame
	if not touch_control.is_visible_in_tree():
		push_error("FAIL: touch input container must remain active in keyboard mode")
		get_tree().quit(1)
		return

	print("touch_control visible=", touch_control.is_visible_in_tree(), " rect=", touch_control.get_global_rect())
	print("joystick visible=", joystick.is_visible_in_tree(), " rect=", joystick.get_global_rect())
	print("window_size=", DisplayServer.window_get_size(), " viewport_size=", get_viewport().get_visible_rect().size)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = Vector2(300, 800)
	press.pressed = true
	get_viewport().push_input(press, true)
	await get_tree().process_frame

	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(420, 800)
	drag.relative = Vector2(120, 0)
	get_viewport().push_input(drag, true)
	await get_tree().process_frame

	print("observed_events=", observed_events)
	print("input_mode=", GameStatusServer.current_input_mode)
	print("touch_control_visible_after_click=", touch_control.is_visible_in_tree())
	print("pressed_signal=", joystick_pressed)
	print("move_right_strength=", Input.get_action_strength(&"move_right"))

	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = Vector2(420, 800)
	release.pressed = false
	get_viewport().push_input(release, true)
	await get_tree().process_frame

	get_tree().quit(0 if joystick_pressed and Input.get_action_strength(&"move_right") == 0.0 else 1)
