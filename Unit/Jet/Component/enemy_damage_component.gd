extends DamageComponent
class_name EnemyDamageComponent

func _special_die_effect() -> void:
	SpwanServer.spwan_flotting_text(global_position)
