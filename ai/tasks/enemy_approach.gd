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
#爬升 或降低水平高度至与玩家一致 

@export var target_var: StringName = &"target"
@export var tolerance: float = 150.0

var enemy : Enemy


func _setup() -> void:
	enemy = agent as Enemy


func _enter() -> void:
	var target := blackboard.get_var(target_var) as Node2D
	
	if is_instance_valid(target):
		if agent.global_position.x - target.global_position.x < 0:
			enemy.target_forward = Vector2.RIGHT
		else :
			enemy.target_forward = Vector2.LEFT


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	
	if not is_instance_valid(target):
		return FAILURE
	
	if agent.global_position.x - target.global_position.x < tolerance:
		return SUCCESS

	return RUNNING
