extends Node

@export var trauma_reduction_rate := 2.0 * 5#抖动恢复 

@export var max_x := 8.0
@export var max_y := 8.0

@export var max_trauma := .88 #限制最大抖动

@export var noise : FastNoiseLite
@export var noise_speed := 50.0

@onready var camera2d : Camera2D = $".." #需要挂载在相机下

var trauma := 0.0
var initial_offset := Vector2.ZERO

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera2d.offset.x = initial_offset.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera2d.offset.y = initial_offset.y + max_y * get_shake_intensity() * get_noise_from_seed(1)

#增加抖动
func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, max_trauma)

#平滑抖动
func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
