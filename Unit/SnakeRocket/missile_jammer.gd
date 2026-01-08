extends Node
class_name MissileJammer

@export var enabled := true

@export var change_interval := 0.1        # 每隔多久换一次方向
@export var max_angle_deg := 360.0          # 最大偏转角度

@export_range(0.0, 1.0, 0.01) var jam_weight := 0.4        # ⭐ 核心权重

@export var smooth := true                 # 是否平滑旋转
@export var rotate_speed := 8.0            # 平滑旋转速度

var _time := 0.0
var _target_dir := Vector2.ZERO
var _current_dir := Vector2.ZERO


func update_jam_dir(delta: float, base_dir: Vector2) -> Vector2:
	if not enabled:
		return Vector2.ZERO

	_time += delta
	if _time >= change_interval:
		_time = 0.0
		_target_dir = _random_dir(base_dir)

	if smooth:
		_current_dir = _current_dir.slerp(_target_dir, 1.0 - exp(-rotate_speed * delta))
	else:
		_current_dir = _target_dir

	return _current_dir


func _random_dir(base_dir: Vector2) -> Vector2:
	var angle = randf_range(
		-deg_to_rad(max_angle_deg),
		deg_to_rad(max_angle_deg)
	)
	return base_dir.rotated(angle).normalized()
