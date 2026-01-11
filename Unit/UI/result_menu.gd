extends CanvasLayer


@onready var battle_compelete: VBoxContainer = $BattleCompelete
@onready var game_over: VBoxContainer = $GameOver

@onready var your_points: Label = $BattleCompelete/VBoxContainer/YourPoints
@onready var enemy_destory: Label = $BattleCompelete/VBoxContainer/EnemyDestory
@onready var rank: Label = $BattleCompelete/VBoxContainer/Rank

func _ready() -> void:
	GameStatusServer.reset_game_status()


func show_result(_battle_complete : bool) -> void:
	if _battle_complete:
		show_battle_result()
	else :
		game_over.show()


func show_battle_result() -> void:
	your_points.text = "Your points : " + str(GameStatusServer.your_points)
	enemy_destory.text = "Enemy Destory : " + str(GameStatusServer.enemy_destory)
	
	for p in GameStatusServer.rank.keys(): #分数评级 
		if GameStatusServer.your_points >= p:
			rank.text = "Rank : " + GameStatusServer.rank[p]
			break


func _on_done_pressed() -> void:
	get_tree().reload_current_scene()
