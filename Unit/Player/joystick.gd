extends Node2D
class_name Joystick

@export var max_len := 70.0
@onready var point: Node2D = $Point

var dragging := false


func _ready() -> void:
	point.position = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			_update_point(event.position)
		else:
			dragging = false
			point.position = Vector2.ZERO

	elif event is InputEventScreenDrag and dragging:
		_update_point(event.position)


func _update_point(global_pos: Vector2) -> void:
	point.global_position = global_pos
	if point.position.length() > max_len:
		point.position = point.position.normalized() * max_len


func get_dir() -> Vector2:
	if point.position.length() < 0.001:
		return Vector2.ZERO
	return point.position.normalized()
