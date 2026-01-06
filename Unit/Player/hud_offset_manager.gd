extends Node2D

#这个管理器会控制所有hud 随着玩家的速度偏移

@export var player : Player
@export var control_list : Dictionary[Control, float]

@export var offset_range := 50.0
