extends JetBase
class_name PlayerJet

var base_accel : float = 1.0
var target_accel : float = 1.0
var burst_accel : float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		burst_accel = 3.0
	if event.is_action_released("ui_accept"):
		target_accel = 1.0


func _get_direction() -> Vector2:
	var target_direction = (get_global_mouse_position() - global_position).normalized()
	direction = direction.lerp(target_direction, .05)
	return direction


func _get_speed() -> float:
	return _get_final_speed()


func _get_final_speed() -> float:
	var _speed = speed
	return _speed * _get_accel() * _get_burst_accel()


func _get_accel() -> float:
	base_accel = lerpf(base_accel, target_accel, .1)
	return base_accel


func _get_burst_accel() -> float:
	burst_accel = lerpf(burst_accel, 1.0, .1)
	return burst_accel
	
