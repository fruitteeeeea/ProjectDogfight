extends Node2D


@export var burst_accel_speed := 1.5


@onready var player: Player = $".."
@onready var camera_2d: PlayerCamera2D = $"../Camera2D"
@onready var burst_trail: CPUParticles2D = $"../Graphic/BurstTrail"
@onready var hud_offset_manager: HUDOffsetManager = $"../HUD/HUDOffsetManager"

var burst_accel := false:
	set(v):
		burst_accel = v
		if v == true:
			print("加速！")
			GameFeel.do_camera_shake(3.0)
			player.engine_on = true
			player.burst_accel = burst_accel_speed
			camera_2d.target_zoom = .9
			burst_trail.emitting = true
			hud_offset_manager.trigger_accel_shake()
			
		else :
			player.burst_accel = 1.0
			camera_2d.target_zoom = camera_2d.defult_zoom
			burst_trail.emitting = false
			

var burst_comsume := 5.0
var burst_recover := 1.0

@onready var progress_bar: ProgressBar = $CanvasLayer/AccelHUD/ProgressBar

#按下之后 开始加速 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		burst_accel = !burst_accel


func _physics_process(delta: float) -> void:
	if progress_bar.value<= 0.0:
		burst_accel = false

	
	if burst_accel:
		progress_bar.value -= delta * burst_comsume
	else :
		progress_bar.value += delta * burst_recover
	
	$CanvasLayer/AccelHUD/Label.text = str(player._get_burst_accel()) + " / " + str(player._get_final_speed())
	
