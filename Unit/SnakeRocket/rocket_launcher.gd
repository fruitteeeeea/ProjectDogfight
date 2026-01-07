extends Node2D

const SNAKE_ROCKET = preload("res://Unit/SnakeRocket/snake_rocket.tscn")

@export var trriger_button := "launch_rocket"
@export var rocket_nb := 5

var up_dir := true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(trriger_button):
		_spwan_rocket()



func _spwan_rocket() -> void:
	for i in range(rocket_nb):
		_launch_rocket()
		await get_tree().create_timer(.2).timeout


func _launch_rocket(nb := 1) -> void:
	var forward := global_transform.x.normalized()
	var angle : float
	
	for i in range(nb):
		var rocket = SNAKE_ROCKET.instantiate()

		if up_dir:
			angle = - PI / 4 - PI /2 
		else :
			angle = PI / 4 + PI /2
		up_dir = !up_dir
		
		rocket.direction = forward.rotated(angle)
		rocket.target_dir = forward
		
		get_tree().current_scene.add_child(rocket)
		rocket.global_position = global_position
		await get_tree().create_timer(.1).timeout
