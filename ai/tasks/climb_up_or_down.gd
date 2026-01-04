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

func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	if not is_instance_valid(target):
		return FAILURE
	
	var a = agent as Enemy
	if agent.global_position.y - target.global_position.y < 0:
		a.target_forward = Vector2.DOWN
	else :
		a.target_forward = Vector2.UP
		
	return SUCCESS
