#*
#* arrive_pos.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTAction
#距离玩家过远 加速飞向玩家 

@export var target_var: StringName = &"target"
@export var tolerance: float = 150.0

@export var movement_speed_buffer := 1.5 #飞向玩家时候的速度 
@export var turn_speed_buffer := 2.5 #转身速度加成 


var enemy : Enemy


func _setup() -> void:
	enemy = agent as Enemy


func _enter() -> void:
	var target := blackboard.get_var(target_var) as Node2D
	
	enemy.movement_speed_buffer = movement_speed_buffer
	enemy.turn_speed_buffer = turn_speed_buffer



func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	
	if not is_instance_valid(target):
		return FAILURE
	

	enemy.target_forward = snap_direction_45((target.global_position - enemy.global_position).normalized())

	return RUNNING

func snap_direction_45(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO

	var angle := dir.angle()                 # 弧度
	var step := PI / 4.0                     # 45°
	var snapped_angle = round(angle / step) * step

	return Vector2.from_angle(snapped_angle)


func _exit() -> void:
	enemy.movement_speed_buffer = 1.0
	enemy.turn_speed_buffer = 1.0
