extends JetBase
class_name Player

var base_accel : float = 1.0
var target_accel : float = 1.0
var burst_accel : float = 1.0:
	set(v):
		burst_accel = v
		print("加速度改变 %s", base_accel)

var force_dir : Vector2 = Vector2.ZERO
var engine_on : bool = true:
	set(v):
		engine_on = v
		if engine_on:
			turn_speed = 2.5
			trail.emitting = true
		else :
			turn_speed = 1.0
			trail.emitting = false

@onready var trail: CPUParticles2D = $Graphic/Trail

func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#burst_accel = 3.0
		#GameFeel.do_camera_shake(1.5)
	#if event.is_action_released("ui_accept"):
		#target_accel = 1.0
	
	if event.is_action_pressed("engine"): #切换引擎状态 
		engine_on = !engine_on


func _apply_force_direction(
	dir: Vector2,
	max_angle_deg := 15.0,
	force_weight := 0.7
) -> Vector2:
	if global_position.y >= 2144.0:
		force_dir = Vector2.UP
	
	elif global_position.y <= -2144.0:
		force_dir = Vector2.DOWN
	
	elif global_position.x >= 3840:
		force_dir = Vector2.LEFT
	
	elif global_position.x <= -3840:
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


#检查引擎是否处于点火状态 点火： 朝着鼠标方向飞行 熄火：朝着地面滑落 
func _check_engine() -> Vector2:
	var final_dir : Vector2
	
	if engine_on:
		final_dir = (get_global_mouse_position() - global_position).normalized()
	else :
		if velocity.x > 0:
			final_dir = Vector2(1, 1)
		else :
			final_dir = Vector2(-1, 1)
	
	return final_dir


func _get_forward(delta) -> Vector2:
	target_forward = _check_engine()
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

#持续加速
func _get_burst_accel() -> float:
	#burst_accel = lerpf(burst_accel, 1.0, .1)
	return burst_accel

#将来还会有一个瞬时加速 
