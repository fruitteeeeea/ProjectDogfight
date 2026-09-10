extends Node
class_name JetMath
#飞机的各种计算功能 

#输入的位置会在这个范围内反复循环 #返回一个循环后的位置 
static func wrap_position(position : Vector2, map_width : float = 640.0, ) -> Vector2:
	return Vector2(fposmod(position.x, map_width), fposmod(position.y, map_width))


#输入当前的位置 会按照时间推移进行旋转 #返回一个旋转后的方向 
static func sprin_direction(delta : float, spin_angle : float, turn_speed : float, direction : Vector2 = Vector2.RIGHT) -> Vector2:
	spin_angle += turn_speed * delta   # turn_speed = 角速度（rad/s）
	return direction.rotated(spin_angle)


#获取带有偏差的目标方向 
static func add_random_offset_to_angle(dir: Vector2, max_deg := 15.0) -> Vector2:
	var angle_offset = randf_range(-max_deg, max_deg)
	return dir.normalized().rotated(deg_to_rad(angle_offset))


#region BIODS 避让逻辑 

#var personal_bias := randf_range(-0.3, 0.3)
#使用方法
#func _get_forward(delta: float) -> Vector2:
	#var sep = SteeringUtils.get_separation(
		#global_position,
		#forward,
		#get_tree().get_nodes_in_group("enemy"),
		#max_separation_dist,
		#0.45
	#)
#
	#var desired = target_forward + sep * separation_weight
#
	#var bias_dir = Vector2(-forward.y, forward.x) * personal_bias
	#desired += bias_dir
#
	#desired = desired.normalized()
	#forward = forward.slerp(desired, 1.0 - exp(-turn_speed * delta))
	#return forward


static func get_separation(
	self_pos: Vector2,
	self_forward: Vector2,
	enemies: Array,
	max_dist: float,
	dot_threshold := 0.3
) -> Vector2:
	var separation := Vector2.ZERO
	var count := 0
	var max_dist_sq := max_dist * max_dist

	for e in enemies:
		if e == null:
			continue

		var to_e = e.global_position - self_pos
		var dist_sq = to_e.length_squared()

		if dist_sq > max_dist_sq or dist_sq < 0.0001:
			continue

		var dist = sqrt(dist_sq)
		var dir_to_e = to_e / dist

		var dot = self_forward.dot(dir_to_e)
		if dot < dot_threshold:
			continue

		var side = Vector2(-self_forward.y, self_forward.x)
		var sign = signf(side.dot(dir_to_e))

		var t = 1.0 - dist / max_dist
		var strength = t * t * dot

		separation += side * sign * strength
		count += 1

	if count > 0:
		separation /= count

	return separation
#endregion
