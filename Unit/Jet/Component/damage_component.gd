extends Node2D
class_name DamageComponent

@export var jet : JetBase
@export var health : float = 10.0

@onready var trail: CPUParticles2D = $"../Graphic/Trail"

@onready var die_particle: CPUParticles2D = $DieParticle
@onready var hit_splash_particle: CPUParticles2D = $HitSplashParticle
@onready var crash_splash_particle: CPUParticles2D = $CrashSplashParticle


func _ready() -> void:
	if !jet:
		printerr("DamageComponent 未找到 JetBase 父节点 ")

#受到伤害 
func take_damage(damage : float) -> void:
	health -= damage
	_hit_effect()
	
	if health <= 0:
		jet.die()
		_die_effect()

#被击中之后的效果 
func _hit_effect() -> void:
	_special_hit_effect()
	GameFeel.do_camera_shake(5.5)
	GameFeel.hit_stop_medium()
	hit_splash_particle.restart()
	hit_splash_particle.emitting = true
	

#子类覆写
func _special_hit_effect() -> void:
	pass


#被击杀之后的效果 
func _die_effect() -> void:
	_special_die_effect()
	crash_splash_particle.emitting = true
	trail.emitting = false
	die_particle.emitting = true


#子类覆写
func _special_die_effect() -> void:
	pass
