extends Node

const PLAYER_SCENE := "res://Unit/Player/player.tscn"
const OLD_JOYSTICK_SCRIPT := "res://Unit/Player/joystick.gd"
const OLD_PLAYER_CONTROL_SCRIPT := "res://Unit/Player/player_control.gd"
const OLD_TOUCH_VISIBILITY_SCRIPT := "res://Unit/Player/player_touch_control.gd"
const MOVE_ACTIONS := [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
]

var failures := 0


func _ready() -> void:
	for action in MOVE_ACTIONS:
		_expect(InputMap.has_action(action), "InputMap action exists: %s" % action)
		_expect(
			is_equal_approx(InputMap.action_get_deadzone(action), 0.15),
			"InputMap deadzone is configured: %s" % action
		)
		for event in InputMap.action_get_events(action):
			_expect(not event is InputEventKey, "movement action has no keyboard binding: %s" % action)

	var packed_scene := load(PLAYER_SCENE) as PackedScene
	_expect(packed_scene != null, "player scene loads")
	if packed_scene != null:
		var player := packed_scene.instantiate()

		var virtual_joystick := player.get_node_or_null("HUD/PlayerTouchControl/MoveJoystick")
		_expect(virtual_joystick is VirtualJoystick, "official VirtualJoystick is present")
		_expect(player.get_node_or_null("PlayerControl") == null, "legacy PlayerControl node is removed")
		_expect(not _has_property(player, &"player_control"), "legacy player_control property is removed")

		if virtual_joystick is VirtualJoystick:
			_expect(virtual_joystick.action_left == &"move_left", "left action is configured")
			_expect(virtual_joystick.action_right == &"move_right", "right action is configured")
			_expect(virtual_joystick.action_up == &"move_up", "up action is configured")
			_expect(virtual_joystick.action_down == &"move_down", "down action is configured")
			_expect(virtual_joystick.joystick_size == 240.0, "joystick size is configured")
			_expect(virtual_joystick.tip_size == 120.0, "tip size is configured")
			_expect(virtual_joystick.deadzone_ratio == 0.0, "VirtualJoystick deadzone is disabled")
			_expect(virtual_joystick.clampzone_ratio == 1.0, "VirtualJoystick clamp zone is configured")
			_expect(virtual_joystick.joystick_mode == VirtualJoystick.JOYSTICK_FOLLOWING, "following mode is configured")
			_expect(virtual_joystick.anchor_top == 0.5, "touch region starts halfway down the screen")
			_expect(
				virtual_joystick.anchor_right > 0.0 and virtual_joystick.anchor_right <= 0.5,
				"touch region stays within the left half of the screen"
			)
			_expect(
				virtual_joystick.get_theme_stylebox(&"normal_joystick") is StyleBoxTexture,
				"base texture style is configured"
			)
			_expect(
				virtual_joystick.get_theme_stylebox(&"normal_tip") is StyleBoxTexture,
				"tip texture style is configured"
			)

		GameStatusServer.current_input_mode = GameStatusServer.InputMode.GAMEPAD
		Input.action_press(&"move_right", 0.25)
		Input.action_press(&"move_down", 0.5)
		var control_direction: Vector2 = player._get_control_direction()
		_expect(is_equal_approx(control_direction.length(), 1.0), "analog input is normalized")
		_expect(control_direction.x > 0.0 and control_direction.y > 0.0, "analog direction is preserved")
		Input.action_release(&"move_right")
		Input.action_release(&"move_down")
		_expect(
			player._get_control_direction().is_equal_approx(control_direction),
			"last direction is retained after releasing the stick"
		)

		GameStatusServer.current_input_mode = GameStatusServer.InputMode.KEYBOARD
		Input.action_press(&"move_left", 1.0)
		_expect(
			player._get_control_direction().is_equal_approx(Vector2.LEFT),
			"active virtual stick input takes priority over mouse mode"
		)
		Input.action_release(&"move_left")

		player.free()

	_expect(not ResourceLoader.exists(OLD_JOYSTICK_SCRIPT), "legacy joystick script is deleted")
	_expect(not ResourceLoader.exists(OLD_PLAYER_CONTROL_SCRIPT), "legacy PlayerControl script is deleted")
	_expect(not ResourceLoader.exists(OLD_TOUCH_VISIBILITY_SCRIPT), "legacy touch visibility script is deleted")

	if failures == 0:
		print("VirtualJoystick migration test passed")
		get_tree().quit(0)
	else:
		push_error("VirtualJoystick migration test failed: %d assertion(s)" % failures)
		get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)


func _has_property(object: Object, property_name: StringName) -> bool:
	for property in object.get_property_list():
		if property.name == property_name:
			return true
	return false
