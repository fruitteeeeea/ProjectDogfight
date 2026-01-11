extends Control

@export var player : Player

@onready var move_direction: TextureRect = $VBoxContainer/Direction/MoveDirection
@onready var forward_direction: TextureRect = $VBoxContainer/Direction/ForwardDirection
@onready var target_forward_direciton: TextureRect = $VBoxContainer/Direction/TargetForwardDireciton
@onready var force_direction: TextureRect = $VBoxContainer/Direction/ForceDirection

@onready var progress_bar_speed: ProgressBar = $VBoxContainer/Info/Speed/ProgressBarSpeed
@onready var progress_bar_accel_speed: ProgressBar = $VBoxContainer/Info/AccelSpeed/ProgressBarAccelSpeed
@onready var progress_bar_turn_speed: ProgressBar = $VBoxContainer/Info/TurnSpeed/ProgressBarTurnSpeed


func _physics_process(delta: float) -> void:
	_handel_player_attitude_arrow()
	_handel_player_attitude_arrow_force()
	
	_handel_player_attitude_info()
	
	
	
func _handel_player_attitude_info() -> void:
	var _speed := snappedf(player._get_final_speed(), .1)
	var _accel_speed := snappedf(player._get_burst_accel(), .1)
	var _turn_speed := snappedf(player.turn_speed, .1)
	
	progress_bar_speed.value = lerpf(progress_bar_speed.value, _speed, .1)
	progress_bar_accel_speed.value = lerpf(progress_bar_accel_speed.value, _accel_speed, .1)
	progress_bar_turn_speed.value = lerpf(progress_bar_turn_speed.value, _turn_speed, .1)



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
