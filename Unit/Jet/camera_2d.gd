extends Camera2D
class_name PlayerCamera2D

@export var target_point : Marker2D

var defult_zoom : float = 1.2
var accel_zoom : float = 0.8
var target_zoom : float = 0.0

func _ready() -> void:
	target_zoom = defult_zoom


func _physics_process(delta: float) -> void:
	if target_point:
		global_position = global_position.lerp(target_point.global_position, .1)

	zoom = zoom.lerp(Vector2.ONE * target_zoom, .05)
