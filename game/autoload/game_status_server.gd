extends Node

signal show_result(complete : bool) #游戏因各种原因结束 展示结算面板 
signal change_input_device(input_mode : InputMode)

signal distribute_rewards

const INPUT_DEVICE_STICK_THRESHOLD := 0.55
const MOUSE_DEADZONE := 16.0

enum BattleState { PREPARING, FREE_FLIGHT, PLAYING, PAUSED, FINISHED }
var manager: Node
var state: BattleState:
	get:
		if is_instance_valid(manager):
			return manager.state
		return BattleState.PREPARING
var battle_epoch := 0
var _points := 0
var _kills := 0
var your_points: int:
	get: return _points
	set(value):
		if is_battle_active():
			_points = value
var enemies_destroyed: int:
	get: return _kills
	set(value):
		if is_battle_active():
			var previous := _kills
			_kills = value
			if _kills > previous and _kills % 5 == 0:
				distribute_rewards.emit()

func is_battle_active() -> bool:
	return state == BattleState.PLAYING

func can_control_player() -> bool:
	return is_instance_valid(manager) and state in [BattleState.FREE_FLIGHT, BattleState.PLAYING]

func can_receive_damage(is_player: bool = false) -> bool:
	return is_battle_active() or (is_player and is_instance_valid(manager) and manager.is_resolving_result())

func record_kill(points: int = 100) -> void:
	if is_battle_active():
		your_points += points
		enemies_destroyed += 1


var rank : Dictionary[int, String] = {
	2500 : "C",
	3000 : "B",
	4500 : "A"
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
	_points = 0
	_kills = 0
	battle_epoch += 1


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		current_input_mode = InputMode.TOUCH_SCREEN
		return
	
	if (
		event is InputEventJoypadButton or 
		(event is InputEventJoypadMotion and abs(event.axis_value) > INPUT_DEVICE_STICK_THRESHOLD)
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
