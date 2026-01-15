extends DamageComponent
class_name PlayerDamageComponent

@export var player_health_hud : PlayerHealthHUD
@export var test_state := true

func take_damage(damage : float) -> void:
	if test_state:
		health += damage
	
	print("玩家被击中 ")
	super(damage)


func _special_hit_effect() -> void:
	GameFeel.hit_stop_long()
	player_health_hud.play_hit_flash()
	player_health_hud.update_rocket_count(health)
