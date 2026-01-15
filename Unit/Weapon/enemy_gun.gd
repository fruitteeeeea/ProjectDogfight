extends Gun
class_name EnemyGun

@export var bullet_number := 1

var can_fire := false

#默认发射方式 不用接受参数 
func fire() -> void:
	if !can_fire:
		return
	
	var player = get_tree().get_first_node_in_group("player") as Player
	var direction = (player.global_position - global_position).normalized()
	
	for i in range(bullet_number):
		_fire(Vector2.ZERO, direction, 5.0)
		await get_tree().create_timer(.05).timeout


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	can_fire = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	can_fire = false
