extends Node2D

@export var speed := 1200.0
@export var wave_amplitude := 330.0
@export var wave_frequency := 58.0
@export var turn_speed := 16.0

@onready var explode_particle: CPUParticles2D = $Graphic/ExplodeParticle
@onready var sprite_2d: Sprite2D = $Graphic/Sprite2D
@onready var trail: Trails = $Graphic/Trail

var target_pos: Vector2
var target_dir : Vector2

var time := 0.0
var direction := Vector2.RIGHT

func _process(delta):
	if not target_pos and not target_dir:
		return

	time += delta

	var to_target : Vector2
	if target_pos:
		to_target = (target_pos - global_position).normalized()
	elif target_dir:
		to_target = target_dir
	
	direction = direction.lerp(to_target, turn_speed * delta).normalized()

	var perpendicular = Vector2(-direction.y, direction.x)
	var wave = perpendicular * sin(time * wave_frequency) * wave_amplitude * delta

	position += direction * speed * delta + wave
	rotation = direction.angle()


func _on_timer_timeout() -> void:
	_explord()


func _explord() -> void:
	sprite_2d.hide()
	trail.active_trail = false
	explode_particle.emitting = true
	await explode_particle.finished
	queue_free()
