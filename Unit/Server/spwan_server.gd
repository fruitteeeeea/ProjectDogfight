extends Node2D

@export var FloattingText : PackedScene
@export var player_reward_list : Array[PackedScene] = []

@export var WORLD_RECT := Rect2(
	Vector2(-3840.0, -2144.0),  # 左上角
	Vector2(7680.0, 4288.0)    # 宽高
)

func spwan_flotting_text(pos : Vector2) -> void:
	var floatting_text = FloattingText.instantiate() as FloattingText
	get_tree().current_scene.add_child(floatting_text)
	floatting_text.global_position = pos


#region SpwanPlayerReward 生成玩家奖励
#生成玩家奖励
func spwan_player_reward() -> void:
	#先获取物品
	var player = get_tree().get_first_node_in_group("player") as Player
	if !player: return
	
	var pos = player.global_position
	var dir = player.forward
	var spwan_pos = get_spawn_position(pos, dir)
	
	var reward = player_reward_list.pick_random().instantiate() as SupplyPacke
	get_tree().current_scene.call_deferred("add_child", reward)
	reward.global_position = spwan_pos


func get_spawn_position(player_pos: Vector2, forward_dir: Vector2 ) -> Vector2:
	var forward := forward_dir.normalized()
	var angle := randf_range(-PI / 2, PI / 2) #前进方向180度的范围。
	var distance := randf_range(888.0, 1222.0)
	var dir := forward.rotated(angle)
	
	var pos := player_pos + dir * distance

	# 限制在 WORLD_RECT 内
	pos.x = clamp(pos.x, WORLD_RECT.position.x, WORLD_RECT.position.x + WORLD_RECT.size.x)
	pos.y = clamp(pos.y, WORLD_RECT.position.y, WORLD_RECT.position.y + WORLD_RECT.size.y)
	return pos

#endregion
