extends Node2D


var game_speed : Array[float] = [0.5, 1.0, 2.0, ]
var current_index : int = 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var speed = _get_next_game_speed() 
		Engine.time_scale = speed
		$CanvasLayer/GameSpeedLabel.text = "当前游戏速度为 %s" % speed


func _get_next_game_speed() -> float:
	current_index = (current_index + 1) % game_speed.size()
	return game_speed[current_index]
