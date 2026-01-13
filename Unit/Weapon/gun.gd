extends Node2D
class_name Gun

@export var BulletScene : PackedScene

#默认发射方式 不用接受参数 
func fire() -> void:
	_fire(Vector2.ZERO, Vector2.RIGHT)


func _fire(pos_offset : Vector2, dir : Vector2, spread_deg : float = 0.0) -> void:
	var bullet = BulletScene.instantiate() as Bullet
	bullet.position = global_position + pos_offset.rotated(global_rotation) #要旋转一下位置的offset
	
	var angle_deg := randf_range(-spread_deg, spread_deg)
	var angle_rad := deg_to_rad(angle_deg)
	bullet.direction = dir.rotated(angle_rad).normalized() #随机角度偏转  
	
	get_tree().current_scene.add_child(bullet)
