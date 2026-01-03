extends Node2D


var health : float = 10.0

func _take_damage(damage : float) -> void:
	_hit_effect()
	print("敌人受到攻击 ")

func _on_hurt_box_body_entered(body: Node2D) -> void:
	_take_damage(10.0)



func _hit_effect() -> void:
	GameFeel.do_camera_shake(1.5)
	GameFeel.hit_stop_short()
