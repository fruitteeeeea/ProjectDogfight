extends Camera2D

@export var target_point : Marker2D
var target_zoom : float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		target_zoom = .8
	if event.is_action_released("ui_accept"):
		target_zoom = 1.0


func _physics_process(delta: float) -> void:
	if target_point:
		global_position = global_position.lerp(target_point.global_position, .1)

	#zoom = zoom.lerp(Vector2.ONE * target_zoom, .1)
