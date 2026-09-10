extends Node


func _ready() -> void:
	var main_game := (load("res://game/core/main_game.tscn") as PackedScene).instantiate()
	var game_hud := main_game.get_node_or_null("GameHUD") as CanvasLayer
	var touch_control := main_game.get_node_or_null("GameHUD/PlayerTouchControl") as Control
	var joystick := main_game.get_node_or_null("GameHUD/PlayerTouchControl/MoveJoystick") as VirtualJoystick

	if game_hud == null:
		push_error("FAIL: GameHUD CanvasLayer is missing")
		get_tree().quit(1)
		return
	if touch_control == null:
		push_error("FAIL: PlayerTouchControl is missing from GameHUD")
		get_tree().quit(1)
		return
	if joystick == null:
		push_error("FAIL: MoveJoystick is not a child of PlayerTouchControl")
		get_tree().quit(1)
		return
	if touch_control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		push_error("FAIL: PlayerTouchControl must not block child touch controls")
		get_tree().quit(1)
		return

	main_game.free()
	print("Touch input layout test passed")
	get_tree().quit(0)
