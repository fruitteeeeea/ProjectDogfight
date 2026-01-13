extends BTAction

@export var target_var: StringName = &"target"


func _tick(_delta: float) -> Status:
	var player := blackboard.get_var(target_var) as Player
	var enemy = agent as Enemy
	
	if not is_instance_valid(player):
		return FAILURE
	
	var player_pos = player.global_position
	var player_forward = player.forward
	var to_player = enemy.global_position - player_pos
	
	
	# cross：判断左右
	var side = player_forward.cross(to_player)
	var evade_dir: Vector2
	
	if side < 0:
		# Probe 在 forward 的“右侧” → 往左逃
		evade_dir = player_forward.orthogonal()
	else:
		# Probe 在 forward 的“左侧” → 往右逃
		evade_dir = -player_forward.orthogonal()
	
	enemy.target_forward = evade_dir

	return SUCCESS
