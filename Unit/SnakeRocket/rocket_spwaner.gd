extends Node2D

const SNAKE_ROCKET = preload("res://Unit/SnakeRocket/snake_rocket.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_spwan_rocket()



func _spwan_rocket() -> void:
	var rocket = SNAKE_ROCKET.instantiate()
	rocket.target_pos = get_global_mouse_position()
	get_tree().current_scene.add_child(rocket)
	rocket.global_position = global_position
