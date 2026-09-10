extends Control
class_name WayPointIcon
#稍后补充一个进入屏幕后不显示的方法

@export var target : Node2D #需要持续追踪的物体

@onready var control: Control = $Control

func _physics_process(delta: float) -> void:
	if visible == false: 
		return
	
	control.position = _get_screen_pos(target)
	control.rotation = _get_rotate_dir()

func _get_screen_pos(target : Node2D) -> Vector2:
	var pos = target.get_viewport_transform() * target.global_position
	var final_pos = get_viewport_transform().affine_inverse() * pos
	return final_pos.clamp(
		Vector2(50, 100),
		Vector2(1920, 1080) - Vector2(100, 50)
	)


func _get_rotate_dir() -> float:
	var screen_center = get_viewport().get_camera_2d().global_position
	var dir = (target.global_position - screen_center)
	if dir.length_squared() > 0.0001:
		return dir.angle()
		
	return 0.0
