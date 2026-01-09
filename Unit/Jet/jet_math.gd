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
