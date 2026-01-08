class_name EnemyMath
# 敌人的各种计算。 纯运算 

static func get_dir_to_player(enemy_pos: Vector2, player_pos: Vector2) -> Vector2:
	return (player_pos - enemy_pos).normalized()


static func is_player_on_right(enemy_pos: Vector2, player_pos: Vector2) -> bool:
	return player_pos.x > enemy_pos.x


static func vertical_relation(enemy_pos: Vector2, player_pos: Vector2) -> float:
	# >0 玩家在上，<0 玩家在下
	return player_pos.y - enemy_pos.y
