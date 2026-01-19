extends Node2D
class_name Joystick

@export var max_len := 120.0

@export var activate_screen_x := 0.45
@export var activate_screen_y := 0.5

@onready var point: Node2D = $Point

var base_pos : Vector2   # 本次拖拽的原点
var dragging := false
var finger_id := -1   # 当前摇杆使用的手指


func _ready() -> void:
	point.position = Vector2.ZERO


func _input(event: InputEvent) -> void:
	# 手指按下（必须在摇杆范围内）
	if event is InputEventScreenTouch and event.pressed:
		if dragging:
			return

		var screen_size := get_viewport().get_visible_rect().size
		if event.position.x > screen_size.x * activate_screen_x:
			return
		if event.position.y < screen_size.y * activate_screen_y:
			return

		dragging = true
		finger_id = event.index
		global_position = event.position #重定位摇杆根节点
		base_pos = event.position
		point.position = Vector2.ZERO
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


func _update_point(screen_pos: Vector2) -> void:
	var offset := screen_pos - base_pos
	offset = offset.limit_length(max_len)
	point.position = offset


func _reset() -> void:
	dragging = false
	finger_id = -1
	point.position = Vector2.ZERO


func get_dir() -> Vector2:
	if point.position.length() < 0.001:
		return Vector2.ZERO
	return point.position.normalized()
