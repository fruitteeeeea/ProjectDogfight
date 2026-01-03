extends CharacterBody2D
class_name JetBase

var direction : Vector2 = Vector2.UP
var speed = 480.0

@onready var graphic: Node2D = $Graphic

func _physics_process(delta: float) -> void:
	
	_handle_movement()
	_hanlde_rotation()


func _handle_movement() -> void:
	velocity = _get_direction() * _get_speed()
	move_and_slide()


func _get_direction() -> Vector2:
	return direction


func _get_speed() -> float:
	return speed


func _hanlde_rotation() -> void:
	graphic.rotation = direction.angle()
