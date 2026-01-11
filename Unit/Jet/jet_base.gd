extends CharacterBody2D
class_name JetBase

@export var WORLD_RECT := Rect2(
	Vector2(-3840.0, -2144.0),  # 左上角
	Vector2(7680.0, 4288.0)    # 宽高
)

var forward : Vector2 = Vector2.UP
var target_forward : Vector2 = Vector2.UP
var move_direction : Vector2 = Vector2.UP

@export var turn_speed := 1.5  # 越大越灵敏
@export var speed = 380.0

@onready var graphic: Node2D = $Graphic

var is_dead := false

func _physics_process(delta: float) -> void:
	
	_handle_movement(delta)
	_hanlde_rotation()


#region MovementSystem
func _handle_movement(delta) -> void:
	move_direction = _get_move_direction(delta)
	velocity = move_direction * _get_speed()
	move_and_slide()


func _get_move_direction(delta) -> Vector2:
	return _get_forward(delta)


func _get_forward(delta) -> Vector2:
	forward = forward.slerp(target_forward, 1.0 - exp(-turn_speed * delta))
	return forward


func _get_speed() -> float:
	return speed


func _hanlde_rotation() -> void:
	graphic.rotation = forward.angle()

#endregion

#region DamageSystem
func take_damage() -> void:
	pass


func die() -> void:
	is_dead = true

#endregion
