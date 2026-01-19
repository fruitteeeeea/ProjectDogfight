extends Node2D
class_name PlayerControl

@export var joystick : Joystick

var joypad_joystick_dir := Vector2.RIGHT

func get_dir() -> Vector2:
	if joystick.get_dir() != Vector2.ZERO: #触屏摇杆拥有最高优先级 
		return joystick.get_dir()
	
	match GameStatusServer.current_input_mode:
		GameStatusServer.InputMode.GAMEPAD:
			return get_joypad_direction()
		GameStatusServer.InputMode.KEYBOARD:
			return get_mouse_direction()
		_:
			return Vector2.UP #实在没有了 默认向上


func get_joypad_direction() -> Vector2:
	var device := 0 # 默认第一个手柄
	var x := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
	var y := Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
	
	var dir := Vector2(x, y)
	
	if dir.length() >= GameStatusServer.STICK_DEADZONE:
		joypad_joystick_dir = dir 
		
	return joypad_joystick_dir


func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()
