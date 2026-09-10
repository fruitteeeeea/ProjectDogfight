extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_game"):
		get_tree().change_scene_to_file("res://game/core/main_game.tscn")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game/core/main_game.tscn")
