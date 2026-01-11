extends Node
class_name BlinkCanvasItem

var canvas_item : CanvasItem

@export_enum("alpha", "color") var blink_mode := "color"

@export var min_value = Color.TRANSPARENT
@export var max_value = Color.WHITE
@export var duration := 0.3
@export var interval := 0.3

@export var enable : bool = true #否则需要手动触发 


func _ready():
	var target = get_parent()
	if target is CanvasItem:
		canvas_item = target

	if enable:
		start_tween()


func start_tween() -> void:
	var prop : NodePath = "modulate"
	
	if blink_mode == "alpha":
		prop = "modulate:a"
		min_value = 0.0
		max_value = 1.0
	
	
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(canvas_item, prop, max_value, duration).from(min_value)
	# ⭐ 停顿 0.5 秒
	tween.tween_interval(interval)
	tween.tween_property(canvas_item, prop, min_value, duration)
