extends Node2D

var health : float = 10.0

@onready var hit_splash_particle: CPUParticles2D = $"../HitSplashParticle"
@export var jet : JetBase


func _ready() -> void:
	if get_parent() is JetBase:
		jet = get_parent()
	else :
		printerr("DamageComponent 未找到 JetBase 父节点 ")


func _take_damage(damage : float) -> void:
	#记得判断 未摧毁的时候 才会接受伤害 
	if jet.is_dead:
		return
	
	jet.die()
	_hit_effect()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	_take_damage(10.0)



func _hit_effect() -> void:
	GameFeel.do_camera_shake(1.5)
	GameFeel.hit_stop_short()
	hit_splash_particle.restart()
	hit_splash_particle.emitting = true
