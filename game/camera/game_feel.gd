extends Node

var camera : Camera2D

func do_camera_shake(strength := 1.5):
	#现场获取相机
	camera = get_viewport().get_camera_2d()
	if !camera:
		print("当前场景未配备相机")
		return
	
	var trauma_component = camera.get_node_or_null("TraumaComponent")
	if !camera.get_node_or_null("TraumaComponent"):
		print("当前相机未配备震屏模块")
		return
	
	trauma_component.add_trauma(strength)

var _hit_stop_generation := 0

func cancel_hit_stop() -> void:
	_hit_stop_generation += 1
	Engine.time_scale = 1.0

func _hit_stop(scale: float, seconds: float) -> void:
	if not GameStatusServer.is_battle_active():
		return
	_hit_stop_generation += 1
	var generation := _hit_stop_generation
	Engine.time_scale = scale
	await get_tree().create_timer(seconds, true, false, true).timeout
	if generation == _hit_stop_generation:
		Engine.time_scale = 1.0

func hit_stop_short() -> void:
	_hit_stop(0.05, 0.02)

func hit_stop_medium() -> void:
	_hit_stop(0.15, 0.08)

func hit_stop_long() -> void:
	_hit_stop(0.0, 0.15)
