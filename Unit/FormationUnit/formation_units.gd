extends Node2D
class_name FormationUnit

@export var target : Marker2D
@export var follow_speed := 3.5

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(
		target.global_position,
		follow_speed * delta
	)
