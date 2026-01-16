extends PlayerJetState


func _setup() -> void:
	player = agent as Player
	print("EngineOn执行一次")

func _enter() -> void:
	player.turn_speed = 2.5
	player.engine_on_particle.emitting = true
	player.trail.emitting = true
	player.flame.emitting = true
	player.engine_on = true
	player.engine_on_label.show()
	player.sfx_engineoff.stop()
	player.sfx_engine_start.play()
	player.sfx_engine.play()
	
	print("玩家进入 EngineOn 状态 ")


func _update(delta: float) -> void:
	if player.force_dir == Vector2.ZERO: #没有强制方向的时候 
		player.target_forward = (player.get_global_mouse_position() - player.global_position).normalized()
	else :
		player.target_forward = _apply_force_direction(player.target_forward)
	
	
	if !player.engine_on && player.force_dir == Vector2.ZERO: #注意 返回战斗区域不会关闭引擎 
		get_root().dispatch(EVENT_FINISHED)


#到达屏幕底部 强制转向 
func _apply_force_direction(
	dir: Vector2,
	max_angle_deg := 15.0,
	force_weight := 0.7
) -> Vector2:
	
	if agent.force_dir.length_squared() > 0.0001:
		var d := dir.normalized()
		var f = agent.force_dir.normalized()

		var dot := d.dot(f)
		var cos_threshold := cos(deg_to_rad(max_angle_deg))

		# 接近时自动解除强制
		if dot >= cos_threshold:
			agent.force_dir = Vector2.ZERO
			return d

		# ⭐ 强制方向作为“偏置” #采用不同的转向速度?
		return d.lerp(f, force_weight).normalized()

	return dir.normalized()


func _exit() -> void:
	player.engine_on_label.hide()
	
	player.sfx_engine_end.play()
	player.sfx_engineoff.play()
	player.sfx_engine.stop()
	print("玩家离开 EngineOn 状态 ")
