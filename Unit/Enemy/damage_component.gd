extends Node2D
class_name DamageComponent

var health : float = 10.0

@export var jet : JetBase

@onready var hit_splash_particle: CPUParticles2D = $"../HitSplashParticle"
@onready var crash_splash_particle: CPUParticles2D = $"../CrashSplashParticle"


func _ready() -> void:
	if get_parent() is JetBase:
		jet = get_parent()
	else :
		printerr("DamageComponent 未找到 JetBase 父节点 ")


func take_damage(damage : float) -> void:
	jet.die()
	_hit_effect()



func _hit_effect() -> void:
	GameFeel.do_camera_shake(5.5)
	GameFeel.hit_stop_medium()
	hit_splash_particle.restart()
	hit_splash_particle.emitting = true
	crash_splash_particle.emitting = true
