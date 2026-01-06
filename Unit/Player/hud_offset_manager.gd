extends Node2D
class_name HUDOffsetManager

#这个管理器会控制所有hud 随着玩家的速度偏移

@export var player : Player
@export var control_list : Dictionary[Control, float]

@export var max_offset := 45.0
@export var follow_speed := 12.0


var shake_offset: Vector2 = Vector2.ZERO #HUD 抖动 
var shake_strength := 0.0
var shake_decay := 80.0

var center_pos: Vector2
var base_positions: Dictionary[Control, Vector2] = {}

func _ready():
	center_pos = get_viewport_rect().size * 0.5
	for ctrl in control_list.keys():
		if ctrl:
			base_positions[ctrl] = ctrl.position


func trigger_accel_shake():
	shake_strength = 45.0


func trigger_hit_shake():
	shake_strength = 50.0


func _physics_process(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var mouse_offset := mouse_pos - center_pos

	var distance := mouse_offset.length()
	var max_mouse_dist := center_pos.length()
	var strength = clamp(distance / max_mouse_dist, 0.0, 1.0)

	# ① 每帧衰减震动（全局一次）
	shake_strength = move_toward(shake_strength, 0, delta * shake_decay)
	shake_offset = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)

	# ② 对每一个 HUD Control 处理
	for ctrl in control_list.keys():
		if not ctrl:
			continue

		var weight := control_list[ctrl]
		var base_pos := base_positions[ctrl]

		# —— 鼠标视差偏移（parallax）
		var parallax_offset := -mouse_offset.normalized()
		parallax_offset *= strength * max_offset * weight

		# —— ⭐ 最终位置合成
		var target_pos = base_pos
		target_pos += parallax_offset
		target_pos += shake_offset * weight

		# —— 平滑移动
		ctrl.position = ctrl.position.lerp(
			target_pos,
			follow_speed * delta
		)
