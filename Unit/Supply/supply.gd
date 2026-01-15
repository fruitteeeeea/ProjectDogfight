extends Node2D
class_name SupplyPacke

@export var player : Player
@onready var area_2d: Area2D = $Area2D

var is_picked := false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and (not is_picked):
		player = body
		player.accelerate_component.acceleration_burst_pack.append(self)
		
		is_picked = true
		area_2d.set_deferred("monitoring", false)
	
	


func _physics_process(delta: float) -> void:
	if player or is_instance_valid(player):
		global_position = global_position.lerp(player.global_position, .1)
