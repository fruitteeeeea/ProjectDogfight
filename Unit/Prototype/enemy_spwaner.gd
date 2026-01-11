extends Node2D

var spwan_pos_x_rand := Vector2(-125, 125)
var spwan_pos_y_rand := Vector2(-1350, 1350)

var x_pos := [-2500, 2500]

@export var EnemyScene : PackedScene
@export var max_enemy_count := 12

func _get_spwan_pos() -> Vector2:
	var posx = x_pos.pick_random() + randf_range(spwan_pos_x_rand.x, spwan_pos_x_rand.y)
	var posy = randf_range(spwan_pos_y_rand.x, spwan_pos_y_rand.y)
	return Vector2(posx, posy)


func _on_timer_timeout() -> void:
	var enemy_count = get_tree().get_node_count_in_group("enemy")
	if enemy_count >= max_enemy_count:
		print("敌人数量超过最大值。当前敌人数量 ： %s" % enemy_count)
		return
	
	for i in range(5):
		var enemy = EnemyScene.instantiate() as Enemy
		var pos = _get_spwan_pos()
		get_tree().current_scene.call_deferred("add_child", enemy)
		enemy.global_position = pos
