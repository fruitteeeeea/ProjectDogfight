extends JetBase
class_name Player

var base_accel : float = 1.0
var target_accel : float = 1.0
var burst_accel : float = 1.0

var force_dir : Vector2 = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		burst_accel = 3.0
		GameFeel.do_camera_shake(1.5)
	if event.is_action_released("ui_accept"):
		target_accel = 1.0


func _apply_force_direction(
	dir: Vector2,
	max_angle_deg := 15.0,
	force_weight := 0.7
) -> Vector2:
	if global_position.y >= 1280.0:
		force_dir = Vector2.UP
	
	elif global_position.y <= -1280.0:
		force_dir = Vector2.DOWN
	
	elif global_position.x >= 1280.0 * 2:
		force_dir = Vector2.LEFT
	
	elif global_position.x <= -1280.0 * 2:
		force_dir = Vector2.RIGHT
	
	
	if force_dir.length_squared() > 0.0001:
		var d := dir.normalized()
		var f := force_dir.normalized()

		var dot := d.dot(f)
		var cos_threshold := cos(deg_to_rad(max_angle_deg))

		# 接近时自动解除强制
		if dot >= cos_threshold:
			force_dir = Vector2.ZERO
			return d

		# ⭐ 强制方向作为“偏置”
		return d.lerp(f, force_weight).normalized()

	return dir.normalized()


func _get_forward(delta) -> Vector2:
	target_forward = (get_global_mouse_position() - global_position).normalized()
	target_forward = _apply_force_direction(target_forward) 
	
	super(delta)
	#forward = forward.lerp(target_forward, .05)
	return forward


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
	
