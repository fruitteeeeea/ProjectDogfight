extends Node

signal show_result(complete : bool) #游戏因各种原因结束 展示结算面板 
signal change_input_device(input_mode : InputMode)


const STICK_DEADZONE := 0.55 #摇杆死区
const MOUSE_DEADZONE := 16.0

var your_points : int = 0
var enemy_destory : int = 0

var rank : Dictionary[int, String] = {
	4500 : "C",
	5000 : "B",
	5500 : "A"
}

enum InputMode {
	TOUCH_SCREEN,
	GAMEPAD,
	KEYBOARD,
}

@export var current_input_mode : InputMode = InputMode.GAMEPAD:
	set(v):
		if current_input_mode != v:
			current_input_mode = v
			change_input_device.emit(current_input_mode)


func reset_game_status() -> void:
	your_points = 0
	enemy_destory = 0


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		current_input_mode = InputMode.TOUCH_SCREEN
		return
	
	if (
		event is InputEventJoypadButton or 
		(event is InputEventJoypadMotion and  abs(event.axis_value) > STICK_DEADZONE)
	):
		current_input_mode = InputMode.GAMEPAD
		return


	if (
		event is InputEventKey or 
		event is InputEventMouseButton or 
		(event is InputEventMouseMotion and event.velocity.length() > MOUSE_DEADZONE)
	):
		current_input_mode = InputMode.KEYBOARD


func is_mobile() -> bool:
	return OS.has_feature("mobile")


func is_pc() -> bool:
	return OS.has_feature("pc")
