extends Node


func _ready() -> void:
	var main_game := (load("res://Main/main_game.tscn") as PackedScene).instantiate()
	var touch_hud := main_game.get_node_or_null("TouchHUD") as CanvasLayer
	var joystick := main_game.get_node_or_null("TouchHUD/MoveJoystick") as VirtualJoystick
	var game_hud := main_game.get_node_or_null("GameHUD") as CanvasLayer

	if touch_hud == null:
		push_error("FAIL: dedicated TouchHUD CanvasLayer is missing")
		get_tree().quit(1)
		return
	if joystick == null:
		push_error("FAIL: MoveJoystick is not a direct child of TouchHUD")
		get_tree().quit(1)
		return
	if game_hud != null and touch_hud.layer <= game_hud.layer:
		push_error("FAIL: TouchHUD must render and receive input above GameHUD")
		get_tree().quit(1)
		return

	print("TouchHUD layer test passed")
	get_tree().quit(0)
