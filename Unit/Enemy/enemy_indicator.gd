extends Control

@onready var control: Control = $Control
@export var enemy : Enemy

var time_eclpase := 0.0

func _physics_process(delta: float) -> void:
	if enemy.is_dead:
		queue_free()
	
	if visible == false: 
		return
	
	var target_pos = _get_screen_pos(enemy)
	target_pos = target_pos.clamp(
		Vector2(50, 100),
		Vector2(1920, 1080) - Vector2(100, 50)
	)
	control.position = target_pos


	var screen_center = get_viewport().get_camera_2d().global_position
	var dir = (enemy.global_position - screen_center)

	if dir.length_squared() > 0.0001:
		control.rotation = dir.angle()
		# 如果贴图默认朝上，用下面这行
		# control.rotation = dir.angle() + PI / 2

	time_eclpase += delta
	if time_eclpase >= .5:
		time_eclpase = 0 



func _get_screen_pos(target : Node2D) -> Vector2:
	var pos = target.get_viewport_transform() * target.global_position
	var final_pos = get_viewport_transform().affine_inverse() * pos
	return final_pos


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	hide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	show()
