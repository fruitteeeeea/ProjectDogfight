extends CanvasLayer

@onready var label: Label = $Control/Label

@export var enable := false
@export var label_title := "GameSpeed : "

@export_enum("Hold", "Click") var trriger_type := "Hold"
@export var game_speed_scale : Array[float] = [.45, 1.0]

var current_index := 1

func _ready() -> void:
	_apply_game_speed(game_speed_scale[current_index])


func _unhandled_input(event: InputEvent) -> void:
	if !enable:
		return
	
	if not event.is_action("game_speed"):
		return

	if trriger_type == "Hold":
		_handle_hold(event)
	else:
		_handle_click(event)


func _handle_hold(event: InputEvent) -> void:
	if event.is_action_pressed("game_speed"):
		_apply_game_speed(game_speed_scale[0])
	elif event.is_action_released("game_speed"):
		_apply_game_speed(game_speed_scale[1])


func _handle_click(event: InputEvent) -> void:
	if event.is_action_pressed("game_speed"):
		current_index = (current_index + 1) % game_speed_scale.size()
		_apply_game_speed(game_speed_scale[current_index])


func _apply_game_speed(speed: float) -> void:
	Engine.time_scale = speed
	label.text = "%s%.2f" % [label_title, speed]
