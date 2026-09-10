extends DamageComponent
class_name EnemyDamageComponent

func _special_die_effect() -> void:
	SpawnServer.spawn_floating_text(global_position)
