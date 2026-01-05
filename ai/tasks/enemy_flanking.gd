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
#选择一个远离玩家的方向 

@export var target_var: StringName = &"target"


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	var a = agent as Enemy
	
	if not is_instance_valid(target):
		return FAILURE
	
	var flank_dir = a.add_random_angle((a.global_position - target.global_position).normalized(), 45.0)
	a.target_forward =  flank_dir#逃离到别的地方 

	return SUCCESS
