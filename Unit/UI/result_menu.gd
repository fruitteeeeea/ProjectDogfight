extends Control
class_name ResultMenu

@onready var battle_compelete: VBoxContainer = $BattleCompelete
@onready var game_over: VBoxContainer = $GameOver

@onready var your_points: Label = $BattleCompelete/VBoxContainer/YourPoints
@onready var enemy_destory: Label = $BattleCompelete/VBoxContainer/EnemyDestory
@onready var rank: Label = $BattleCompelete/VBoxContainer/Rank

@onready var result: Label = $GameOver/HBoxContainer/Result
@onready var blur_background: ColorRect = $BlurBackground

@onready var retry: Button = $Retry

func _ready() -> void:
	GameStatusServer.reset_game_status()
	GameStatusServer.show_result.connect(_show_result)


func _show_result(_battle_complete : bool) -> void:
	if _battle_complete:
		_show_battle_result()
	else :
		_show_game_over()
	
	blur_background.show()
	retry.show()


func _show_battle_result() -> void:
	your_points.text = "Your points : " + str(GameStatusServer.your_points)
	enemy_destory.text = "Enemy Destory : " + str(GameStatusServer.enemy_destory)
	
# 1. 获取所有阈值并从大到小排序
	var thresholds = GameStatusServer.rank.keys()
	thresholds.sort_custom(func(a, b): return a < b)
	
	# 2. 遍历并比较
	for threshold in thresholds:
		if GameStatusServer.your_points >= threshold:
			rank.text = "Rank : " + GameStatusServer.rank[threshold]
	
	battle_compelete.show()
	_display_box(battle_compelete)


func _show_game_over() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	if player.is_dead:
		result.text = "Jet has been destory"
		
	_display_text(result)
	game_over.show()
	_display_box(game_over)


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


#region Tween
func _display_text(label : Label) -> void:
	label.visible_ratio = 0.0
	
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "visible_ratio", 1.0, 1.0)


func _display_box(box : VBoxContainer) -> void:
	box.position.x = -1080
	box.modulate.a = 0.0
	blur_background.material.set_shader_parameter("blur_amount", 0.0)
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(box, "position:x", 0.0, .3)
	tween.tween_property(box, "modulate:a", 1.0, .3)
	tween.tween_property(blur_background.material, "shader_parameter/blur_amount", 4.0, 1.0)
#endregion
