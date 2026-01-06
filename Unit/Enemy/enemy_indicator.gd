extends Control

@onready var control: Control = $Control
@export var enemy : Enemy

var time_eclpase := 0.0

func _physics_process(delta: float) -> void:
	if enemy.is_dead:
		queue_free()
	
	var target_pos = _get_screen_pos(enemy)
	target_pos = target_pos.clamp(
		Vector2(50, 100),
		Vector2(1920, 1080) - Vector2(100, 50)
	)
	control.position = target_pos
	
	time_eclpase += delta
	if time_eclpase >= .5:
		print(_get_screen_pos(enemy))
		print(control.position)
		time_eclpase = 0 



func _get_screen_pos(target : Node2D) -> Vector2:
	var pos = target.get_viewport_transform() * target.global_position
	var final_pos = get_viewport_transform().affine_inverse() * pos
	return final_pos


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	hide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	show()
