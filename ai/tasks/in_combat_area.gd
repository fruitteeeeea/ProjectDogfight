#*
#* in_range.gd
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

#检查敌人是否在战斗区域内 
#如果不是的话 直接返回到作战区域 
# Called to generate a display name for the task.
func _generate_name() -> String:
	return "InCombatArea"


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	var enemy = agent as Enemy
	var WORLD_RECT : Rect2 = enemy.WORLD_RECT
	var new_rect : Rect2 = Rect2(WORLD_RECT.position * .9, WORLD_RECT.size * .9)

	if new_rect.has_point(enemy.global_position):
		return SUCCESS
	
	return FAILURE
