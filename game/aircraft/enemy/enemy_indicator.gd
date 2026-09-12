extends WayPointIcon
class_name EnemyIndicator

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or (target is Enemy and target.is_dead):
		queue_free()
		return
	super(delta)
