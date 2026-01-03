extends Node2D


@export var BulletScene : PackedScene

@export var fire_interval : float = .1

@onready var fire_interval_timer: Timer = $fire_interval_timer

var fire_on : bool = true:
	set(v):
		fire_on = v
		if fire_on:
			fire_interval_timer.start(fire_interval)
		else :
			fire_interval_timer.stop()


func _ready() -> void:
	fire_interval_timer.wait_time = fire_interval


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		fire_on = !fire_on


func _fire() -> void:
	var bullet = BulletScene.instantiate() as Bullet
	bullet.position = global_position
	bullet.direction = global_transform.x.normalized()
	get_tree().current_scene.add_child(bullet)


func _on_fire_interval_timer_timeout() -> void:
	_fire() 
