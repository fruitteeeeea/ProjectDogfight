#*
#* is_aligned_with_target.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTCondition

@export var target_var: StringName = &"target"
@export var tolerance: float = 75.0

var cos_limit : float

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "IsSameDirectionWithTarget " + LimboUtility.decorate_var(target_var)

func _setup() -> void:
	cos_limit = cos(deg_to_rad(tolerance))
	print(cos_limit)


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Player
	var enemy := agent as Enemy
	
	if not is_instance_valid(target) or not is_instance_valid(enemy):
		return FAILURE
	
	var dot := target.forward.normalized().dot(enemy.forward.normalized())

	# 同向（偏差 ≤ 75°）
	if dot >= cos_limit:
		return SUCCESS

	else:
		return FAILURE
