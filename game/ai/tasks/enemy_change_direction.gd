extends BTAction

func _tick(_delta: float) -> Status:
	var enemy = agent as Enemy
	if enemy.velocity.x > 0.0:
		enemy.target_forward = Vector2.LEFT
	else :
		enemy.target_forward = Vector2.RIGHT
	
	return SUCCESS
