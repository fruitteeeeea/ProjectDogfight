extends Node2D

var speed_up := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		speed_up = !speed_up
		if speed_up:
			Engine.time_scale = 2.0
		else :
			Engine.time_scale = 1.0
