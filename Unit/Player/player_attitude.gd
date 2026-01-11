extends Control

@export var player : Player

@onready var move_direction: TextureRect = $VBoxContainer/Direction/MoveDirection
@onready var forward_direction: TextureRect = $VBoxContainer/Direction/ForwardDirection
@onready var target_forward_direciton: TextureRect = $VBoxContainer/Direction/TargetForwardDireciton
@onready var force_direction: TextureRect = $VBoxContainer/Direction/ForceDirection

func _physics_process(delta: float) -> void:
	_handel_player_attitude_arrow()
	_handel_player_attitude_arrow_force()


#region ForceDirection
func _handel_player_attitude_arrow() -> void:
	move_direction.rotation = player.velocity.angle()
	forward_direction.rotation = player.forward.angle()
	target_forward_direciton.rotation = player.target_forward.angle()

func _handel_player_attitude_arrow_force() -> void:
	if player.force_dir != Vector2.ZERO:
		force_direction.show()
		force_direction.rotation =  player.force_dir.angle() 
	else:
		if force_direction.visible == true:
			force_direction.hide()
#endregion 
