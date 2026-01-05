extends Node2D

var spwan_pos_x_rand := Vector2(-25, 25)
var spwan_pos_y_rand := Vector2(-1350, 1350)

var x_pos := [-2500, 2500]

@export var EnemyScene : PackedScene


func _get_spwan_pos() -> Vector2:
	var posx = x_pos.pick_random() + randf_range(spwan_pos_x_rand.x, spwan_pos_x_rand.y)
	var posy = randf_range(spwan_pos_y_rand.x, spwan_pos_y_rand.y)
	return Vector2(posx, posy)


func _on_timer_timeout() -> void:
	var enemy = EnemyScene.instantiate() as Enemy
	var pos = _get_spwan_pos()
	get_tree().current_scene.call_deferred("add_child", enemy)
	enemy.global_position = pos
