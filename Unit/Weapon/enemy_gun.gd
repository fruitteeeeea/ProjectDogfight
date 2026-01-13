extends Gun
class_name EnemyGun

@export var bullet_number := 1

#默认发射方式 不用接受参数 
func fire() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	var direction = (player.global_position - global_position).normalized()
	
	for i in range(bullet_number):
		_fire(Vector2.ZERO, direction, 5.0)
		await get_tree().create_timer(.05).timeout
