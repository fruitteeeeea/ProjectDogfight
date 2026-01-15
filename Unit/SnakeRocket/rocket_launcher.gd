extends Node2D
class_name RocketLauncher

@export var trriger_button := "launch_rocket"
@export var SnakeRocketScene : PackedScene
@export var rocket_slot : RocketSlot

@export var max_rocket_nb := 4
@export var reloading_time := 3.0 #每2秒装填一个子弹 
var current_rocket_nb := 0:
	set(v):
		current_rocket_nb = v
		rocket_slot.update_rocket_count(v)

var up_dir := true

@onready var reloading_timer: Timer = $ReloadingTimer

func _ready() -> void:
	await get_tree().process_frame
	current_rocket_nb = max_rocket_nb
	reloading_timer.start(reloading_time)
	


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(trriger_button):
		if current_rocket_nb > 0: 
			current_rocket_nb -= 1
			_launch_rocket() #手动发射导弹 


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


func _on_timer_timeout() -> void:
	current_rocket_nb = min(current_rocket_nb + 1, max_rocket_nb)
