extends Node2D
class_name RocketLauncher

@export var SnakeRocketScene : PackedScene

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


func _launch_rocket(dir :float = 1 , nb := 1, interval := .1, jam := 0.0) -> void:
	var forward := global_transform.x.normalized() * (Vector2.ONE * dir)
	var angle : float
	
	for i in range(nb):
		var rocket = SnakeRocketScene.instantiate()

		if up_dir:
			angle = - PI / 4 - PI /2 
		else :
			angle = PI / 4 + PI /2
		up_dir = !up_dir
		
		rocket.jam_weight = jam
		rocket.direction = forward.rotated(angle)
		rocket.target_dir = forward
		
		get_tree().current_scene.add_child(rocket)
		rocket.global_position = global_position
		await get_tree().create_timer(.1).timeout
