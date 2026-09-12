extends Control

func _ready() -> void:
	if GameStatusServer.is_mobile() and GameStatusServer.can_control_player():
		show()
	GameStatusServer.change_input_device.connect(_change_display)


func _change_display(mode : GameStatusServer.InputMode) -> void:
	if mode == GameStatusServer.InputMode.TOUCH_SCREEN and GameStatusServer.can_control_player():
		show()
	else :
		hide()

func reset_touch_input() -> void:
	hide()
	# The native joystick has no public gesture reset API. Recreate it to
	# discard an in-progress touch capture while retaining its configuration.
	var old: VirtualJoystick = $MoveJoystick
	var replacement := old.duplicate() as VirtualJoystick
	remove_child(old)
	old.queue_free()
	add_child(replacement)
