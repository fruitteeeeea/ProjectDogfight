extends JetBase
class_name Enemy


func _ready() -> void:
	target_forward = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()


#获取带有偏差的目标方向 
func add_random_angle(dir: Vector2, max_deg := 15.0) -> Vector2:
	var angle_offset = randf_range(-max_deg, max_deg)
	return dir.normalized().rotated(deg_to_rad(angle_offset))
