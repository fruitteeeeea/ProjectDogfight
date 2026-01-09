extends BTAction


func _tick(_delta: float) -> Status:
	var enemy = agent as Enemy
	var direction_offset = [0, 0, -15, 15].pick_random()
	
	if enemy.velocity.x > 0.0:
		enemy.target_forward = Vector2.RIGHT.rotated(deg_to_rad(direction_offset))
	else :
		enemy.target_forward = Vector2.LEFT.rotated(deg_to_rad(direction_offset))
	
	prints(enemy.target_forward)
	return SUCCESS
