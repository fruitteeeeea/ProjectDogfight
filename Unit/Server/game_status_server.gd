extends Node

var your_points : int = 0
var enemy_destory : int = 0

var rank : Dictionary[int, String] = {
	1000 : "C",
	2000 : "B",
	3000 : "A"
}

func reset_game_status() -> void:
	your_points = 0
	enemy_destory = 0
