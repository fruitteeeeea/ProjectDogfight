extends Node2D
var spawn_pos_x_rand := Vector2(-125, 125)
var spawn_pos_y_rand := Vector2(-1350, 1350)
var x_pos := [-2500, 2500]
@export var EnemyScene: PackedScene
@export var max_enemy_count := 12
@export var spawn_batch := 5
var pending_count := 0

func living_count() -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy and not enemy.is_dead:
			count += 1
	return count

func _get_spawn_pos() -> Vector2:
	return Vector2(x_pos.pick_random() + randf_range(spawn_pos_x_rand.x, spawn_pos_x_rand.y), randf_range(spawn_pos_y_rand.x, spawn_pos_y_rand.y))

func _on_timer_timeout() -> void:
	if not GameStatusServer.is_battle_active():
		return
	var count := mini(spawn_batch, maxi(0, max_enemy_count - living_count() - pending_count))
	for i in range(count):
		pending_count += 1
		_spawn_enemy.call_deferred(GameStatusServer.battle_epoch)

func _spawn_enemy(epoch: int) -> void:
	pending_count -= 1
	if not GameStatusServer.is_battle_active() or epoch != GameStatusServer.battle_epoch:
		return
	var enemy := EnemyScene.instantiate() as Enemy
	enemy.position = _get_spawn_pos()
	get_tree().current_scene.add_child(enemy)
