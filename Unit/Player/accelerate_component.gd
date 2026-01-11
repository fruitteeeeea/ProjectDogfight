extends Node2D


@export var trriger_button := "ui_accept"
@export var burst_accel_speed := 1.8

@export var max_burst_accel_fuel := 20.0
@export var burst_comsume := 5.0
@export var burst_recover := 1.0

@export var rocket_launcher : RocketLauncher

@onready var player: Player = $".."
@onready var camera_2d: PlayerCamera2D = $"../Camera2D"
@onready var burst_trail: CPUParticles2D = $"../Graphic/BurstTrail"
@onready var hud_offset_manager: HUDOffsetManager = $"../HUD/HUDOffsetManager"
@onready var progress_bar: ProgressBar = $CanvasLayer/AccelHUD/ProgressBar

@onready var accel_and_speed: Label = $CanvasLayer/AccelHUD/AccelAndSpeed

var burst_accel := false:
	set(v):
		burst_accel = v
		if v == true:
			print("加速！")
			
			rocket_launcher._launch_rocket(-.1, 5, .05, 1.0) #朝后方发射热诱弹 
			
			GameFeel.do_camera_shake(3.0)
			player.engine_on = true
			player.burst_accel = burst_accel_speed
			camera_2d.target_zoom = camera_2d.accel_zoom
			burst_trail.emitting = true
			hud_offset_manager.trigger_accel_shake()
			
		else :
			player.burst_accel = 1.0
			camera_2d.target_zoom = camera_2d.defult_zoom
			burst_trail.emitting = false

func _ready() -> void:
	progress_bar.max_value = max_burst_accel_fuel
	progress_bar.value = max_burst_accel_fuel


#按下之后 开始加速 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(trriger_button):
		burst_accel = !burst_accel


func _physics_process(delta: float) -> void:
	if progress_bar.value<= 0.0:
		burst_accel = false

	
	if burst_accel:
		progress_bar.value -= delta * burst_comsume
	else :
		progress_bar.value += delta * burst_recover
	
	accel_and_speed.text = str(snappedf(player._get_burst_accel(), .1)) + " / " + str(snappedf(player._get_final_speed(), .1))
