extends CharacterBody2D
class_name JetBase

@export var forward : Vector2 = Vector2.UP
var target_forward : Vector2 = Vector2.UP

@export var turn_speed := 2.0  # 越大越灵敏
@export var speed = 380.0

@onready var graphic: Node2D = $Graphic

var is_dead := false

func _physics_process(delta: float) -> void:
	
	_handle_movement(delta)
	_hanlde_rotation()


func take_damage() -> void:
	pass


func die() -> void:
	is_dead = true


func _handle_movement(delta) -> void:
	velocity = _get_forward(delta) * _get_speed()
	move_and_slide()


func _get_forward(delta) -> Vector2:
	forward = forward.slerp(target_forward, 1.0 - exp(-turn_speed * delta))
	return forward


func _get_speed() -> float:
	return speed


func _hanlde_rotation() -> void:
	graphic.rotation = forward.angle()
