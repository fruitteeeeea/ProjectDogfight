extends Node2D
var _starting := false

func _input(event: InputEvent) -> void:
	if not $CanvasLayer/Control/TouchToStart.visible:
		return
	if event is InputEventKey and event.echo:
		return
	var pointer_pressed: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	if pointer_pressed or event.is_action_pressed("start_game"):
		get_viewport().set_input_as_handled()
		_on_play_pressed()

func _on_play_pressed() -> void:
	if _starting:
		return
	_starting = true
	get_tree().change_scene_to_file("res://game/core/main_game.tscn")
