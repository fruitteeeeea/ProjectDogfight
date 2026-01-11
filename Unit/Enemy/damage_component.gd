extends Node2D
class_name DamageComponent

const FLOATTING_TEXT = preload("res://Unit/UI/floatting_text/floatting_text.tscn")

var health : float = 10.0

@export var jet : JetBase

@onready var trail: CPUParticles2D = $"../Graphic/Trail"

@onready var die_particle: CPUParticles2D = $DieParticle
@onready var hit_splash_particle: CPUParticles2D = $HitSplashParticle
@onready var crash_splash_particle: CPUParticles2D = $CrashSplashParticle

func _ready() -> void:
	if !jet:
		printerr("DamageComponent 未找到 JetBase 父节点 ")


func take_damage(damage : float) -> void:
	jet.die()
	_hit_effect()



func _hit_effect() -> void:
	$"../FloattingText".show()
	GameFeel.do_camera_shake(5.5)
	GameFeel.hit_stop_medium()
	hit_splash_particle.restart()
	hit_splash_particle.emitting = true
	crash_splash_particle.emitting = true
	trail.emitting = false
	die_particle.emitting = true
