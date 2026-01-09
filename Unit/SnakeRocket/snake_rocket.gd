extends Node2D
class_name SnakeRocket
#蛇形导弹 

@export var speed := 800.0
@export var wave_amplitude := 330.0
@export var wave_frequency := 58.0
@export var turn_speed := 16.0

@export var jam_weight := 0.0
@onready var missile_jammer: MissileJammer = $MissileJammer

@onready var graphic: Node2D = $Graphic
@onready var detect_area: Area2D = $DetectArea
@onready var explode_particle: CPUParticles2D = $Graphic/ExplodeParticle
@onready var sprite_2d: Sprite2D = $Graphic/Sprite2D
@onready var trail: Trails = $Graphic/Trail
@onready var color_rect: ColorRect = $"2DWorldLabel/ColorRect"
@onready var label: Label = $"2DWorldLabel/Label"


var target : Node2D:
	set(v):
		target = v
		color_rect.color = Color.RED
		label.text = "found!"

var target_dir : Vector2
var target_pos: Vector2 


var time := 0.0
var direction := Vector2.RIGHT


func _ready() -> void:
	missile_jammer.jam_weight = jam_weight #赋值扰流权重 


func _process(delta):
	var to_target : Vector2 #这个是导弹最终前进方向 

	if target != null or is_instance_valid(target): #目标敌人的优先级最高 
		if global_position.distance_squared_to(target.global_position) <= 100:
			_explord()
		
		to_target = (target.global_position - global_position).normalized()
		
	elif target_dir != Vector2.ZERO:
		to_target = target_dir.normalized()
		
	elif target_pos != null:
		to_target = (target_pos - global_position).normalized()
	else:
		return
	
	time += delta
	
	var jam_dir = missile_jammer.update_jam_dir(delta, to_target) #热诱弹 
	if jam_dir != Vector2.ZERO:
		to_target = to_target.slerp(jam_dir, missile_jammer.jam_weight).normalized()

	
	direction = direction.lerp(to_target, turn_speed * delta).normalized()

	var perpendicular = Vector2(-direction.y, direction.x)
	var wave = perpendicular * sin(time * wave_frequency) * wave_amplitude * delta

	position += direction * speed * delta + wave
	graphic.rotation = direction.angle()


func _on_timer_timeout() -> void:
	_explord()


func _explord() -> void:
	sprite_2d.hide()
	trail.active_trail = false
	explode_particle.emitting = true
	
	for e in detect_area.get_overlapping_bodies():
		if e is Enemy:
			e.take_damage()
	
	await explode_particle.finished
	queue_free()


func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if !body.is_dead:
			target = body
