extends Node2D

const SNAKE_ROCKET = preload("res://Unit/SnakeRocket/snake_rocket.tscn")

var up_dir := true

@export var player : PlayerJet

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_spwan_rocket()



func _spwan_rocket() -> void:
	for i in range(5):
		_launch_rocket()
		await get_tree().create_timer(.1).timeout


func _launch_rocket() -> void:
	var forward := global_transform.x.normalized()
	if player:
		forward = player.velocity.normalized()
	
	
	var angle : float
	
	for i in range(2):
		var rocket = SNAKE_ROCKET.instantiate()

		if up_dir:
			angle = - PI / 4
		else :
			angle = PI / 4
		up_dir = !up_dir
		rocket.target_dir = forward.rotated(angle)
		
		get_tree().current_scene.add_child(rocket)
		rocket.global_position = global_position
		await get_tree().create_timer(.1).timeout
