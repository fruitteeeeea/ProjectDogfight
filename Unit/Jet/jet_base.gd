extends CharacterBody2D
class_name JetBase

const MAP_WIDTH := 640.0

var forward : Vector2 = Vector2.UP
var speed = 480.0

@onready var graphic: Node2D = $Graphic

func _physics_process(delta: float) -> void:
	
	_handle_movement(delta)
	_hanlde_rotation()


func _handle_movement(delta) -> void:
	velocity = _get_forward(delta) * _get_speed()
	move_and_slide()


#func _wrap_position():
	#global_position.x = fposmod(global_position.x, MAP_WIDTH)
	#global_position.y = fposmod(global_position.y, MAP_WIDTH)

func _get_forward(delta) -> Vector2:
	return forward


func _get_speed() -> float:
	return speed


func _hanlde_rotation() -> void:
	graphic.rotation = forward.angle()
