extends Node

signal show_result(complete : bool) #游戏因各种原因结束 展示结算面板 


var your_points : int = 0
var enemy_destory : int = 0

var rank : Dictionary[int, String] = {
	4500 : "C",
	5000 : "B",
	5500 : "A"
}

func reset_game_status() -> void:
	your_points = 0
	enemy_destory = 0
