extends Control

@export var player : Player

@export_enum("y", "x") var axis_track := "y"

@export var player_y_min := -2136.0
@export var player_y_max := 2136.0
@export var scale_y_min := -3584.0
@export var scale_y_max := 0.0

@onready var player_position_indicator: Label = $PlayerPositionIndicator
@onready var scale_texture: TextureRect = $Control/CanvasGroup/ScaleTexture

func _physics_process(delta: float) -> void:
	player_position_indicator.text = str(player.global_position)
	_update_scale_line()


#更新刻度线 
func _update_scale_line() -> void:
	var pos : float
	if axis_track == "y":
		pos = player.global_position.y
	else :
		pos = player.global_position.x
	scale_texture.position.y = map_player_y(pos)


func map_player_y(player_y: float) -> float:
	return remap(
		clamp(player_y, player_y_min, player_y_max),
		player_y_max, player_y_min,
		scale_y_max, scale_y_min
	)
