extends Node2D
class_name DamageComponent

signal health_change(health : float)

@export var jet : JetBase
@export var max_health : float = 40.0
@export var health : float = 0.0:
	set(v):
		health = v
		health_change.emit(health)

@onready var trail: CPUParticles2D = $"../Graphic/Trail"

@onready var die_particle: CPUParticles2D = $DieParticle
@onready var hit_splash_particle: CPUParticles2D = $HitSplashParticle
@onready var crash_splash_particle: CPUParticles2D = $CrashSplashParticle

@onready var sfx_explode: AudioStreamPlayer2D = $SFXExplode

func _ready() -> void:
	if !jet:
		printerr("DamageComponent 未找到 JetBase 父节点 ")
	
	health = max_health

#受到伤害 
func take_damage(damage : float) -> void:
	health = clamp(health - damage, 0, max_health)
	
	if damage < 0:
		_heal_effect()
		return
	
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


func _special_hit_effect() -> void:
	pass


#治疗效果
func _heal_effect() -> void:
	_special_heal_effect()


func _special_heal_effect() -> void:
	pass


#子类覆写



#被击杀之后的效果 
func _die_effect() -> void:
	_special_die_effect()
	crash_splash_particle.emitting = true
	trail.emitting = false
	die_particle.emitting = true
	sfx_explode.play()


#子类覆写
func _special_die_effect() -> void:
	pass
