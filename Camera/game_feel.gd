extends Node

var camera : Camera2D

func do_camera_shake(strength := 1.5):
	#现场获取相机
	camera = get_viewport().get_camera_2d()
	if !camera:
		print("当前场景未配备相机")
		return
	
	var truma_component = camera.get_node_or_null("TrumaComponent")
	if !camera.get_node_or_null("TrumaComponent"):
		print("当前相机未配备震屏模块")
		return
	
	truma_component.add_trauma(strength)

func hit_stop_short():
	Engine.time_scale = 0.05
	await get_tree().create_timer(0.02, true, false, true).timeout
	Engine.time_scale = 1

#时间减慢
func hit_stop_medium():
	Engine.time_scale = 0.15
	await get_tree().create_timer(0.08, true, false, true).timeout
	Engine.time_scale = 1

func hit_stop_long():
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1
