extends Node2D
class_name SupplyPacke

@export var follow_mode : bool = true

var player : Player
var is_picked := false

@onready var area_2d: Area2D = $Area2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and (not is_picked):
		player = body
		_player_claim_supply()
		
		is_picked = true
		area_2d.set_deferred("monitoring", false)
		
		SoundManager.play_sfx("SFXSupplyClaim")
		
		if !follow_mode:
			queue_free()


func _physics_process(delta: float) -> void:
	if player or is_instance_valid(player):
		global_position = global_position.lerp(player.global_position, .1)


#子类覆写 玩家获得补给
func _player_claim_supply() -> void:
	player.accelerate_component.acceleration_burst_pack.append(self)
