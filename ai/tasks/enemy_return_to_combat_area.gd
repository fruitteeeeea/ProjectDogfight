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
#根据自身位置 选择返回作战区域的方向 

var enemy : Enemy

func _setup() -> void:
	enemy = agent


func _tick(_delta: float) -> Status:
	var final_dir = JetMath.add_random_offset_to_angle((Vector2.ZERO - enemy.global_position).normalized(), 90.0)
	enemy.target_forward = final_dir
	return SUCCESS


func _is_dircetion_legal() -> bool:
	#可以使用dot来确认方向是否 合法 
	#因为来到这里了 不能再选择远离战斗中心的方向了 
	return true
