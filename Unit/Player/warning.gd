extends Control

@onready var color_rect: ColorRect = $HBoxContainer/PanelContainer/ColorRect

@export var min_alpha := 0.0
@export var max_alpha := 1.0
@export var duration := 0.1

func _ready():
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(color_rect, "color:a", max_alpha, duration).from(min_alpha)
	tween.tween_property(color_rect, "color:a", min_alpha, duration)
