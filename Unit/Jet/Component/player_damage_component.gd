extends DamageComponent
class_name PlayerDamageComponent

@export var test_state := true

@onready var sfx_hit: AudioStreamPlayer2D = $SFXHit

func take_damage(damage : float) -> void:
	if test_state:
		health += damage
	
	print("玩家被击中 ")
	super(damage)


func _special_hit_effect() -> void:
	GameFeel.hit_stop_long()
	sfx_hit.play()
