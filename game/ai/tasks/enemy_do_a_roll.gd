extends BTAction


var spin_left := 0.0
var spin_speed := deg_to_rad(720 * 3)

var enemy : Enemy
var spin_turn_speed : float = 4.5
var defult_turn_speed : float

func _setup() -> void:
	enemy = agent
	defult_turn_speed = enemy.turn_speed


func _enter() -> void:
	enemy.turn_speed = spin_turn_speed
	spin_left = TAU


func _tick(delta: float) -> Status:
	if spin_left > 0.0:
		var step = min(spin_speed * delta, spin_left)
		enemy.target_forward = enemy.forward.rotated(step)
		spin_left -= step
	else:
		return SUCCESS
		
	return RUNNING


func _exit() -> void:
	enemy.turn_speed = defult_turn_speed
