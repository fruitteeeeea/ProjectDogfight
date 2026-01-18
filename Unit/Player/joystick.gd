extends Node2D
class_name Joystick

@export var max_len := 120.0

@onready var point: Node2D = $Point

var dragging := false
var finger_id := -1   # 当前摇杆使用的手指


func _ready() -> void:
	point.position = Vector2.ZERO


func _input(event: InputEvent) -> void:
	# 手指按下（必须在摇杆范围内）
	if event is InputEventScreenTouch and event.pressed:
		if dragging:
			return

		# 👉 范围判断
		if event.position.distance_to(global_position) > max_len:
			return

		dragging = true
		finger_id = event.index
		_update_point(event.position)
		return

	# 手指抬起（只响应自己的手指）
	if event is InputEventScreenTouch and not event.pressed:
		if event.index == finger_id:
			_reset()
		return

	# 拖拽（只响应自己的手指）
	if event is InputEventScreenDrag:
		if dragging and event.index == finger_id:
			_update_point(event.position)


func _update_point(global_pos: Vector2) -> void:
	point.global_position = global_pos
	if point.position.length() > max_len:
		point.position = point.position.normalized() * max_len


func _reset() -> void:
	dragging = false
	finger_id = -1
	point.position = Vector2.ZERO


func get_dir() -> Vector2:
	if point.position.length() < 0.001:
		return Vector2.ZERO
	return point.position.normalized()
