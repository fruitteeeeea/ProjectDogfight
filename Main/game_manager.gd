extends Node2D

@onready var ready_to_start: Control = $"../GameHUD/ReadyToStart"
@onready var result_menu: ResultMenu = $"../GameHUD/ResultMenu"


@export var mission_time : float = 60

@export var player : Player
var mission_panel : MissionPanel

var game_start := false


func _ready() -> void:
	await get_tree().process_frame #先等所有节点ready
	mission_panel = player.misson


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("StartTheGame"):
		if !game_start:
			_start_the_game()


func _start_the_game() -> void:
	ready_to_start.queue_free()
	var target_points : int = GameStatusServer.rank.keys()[0] #通关最低分数
	mission_panel.mission_start(mission_time, target_points)
	
	game_start = true
