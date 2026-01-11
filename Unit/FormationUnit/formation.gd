extends Node2D

const FORMATION_UNITS = preload("res://Unit/FormationUnit/formation_units.tscn")

var formation_index := [-2, -1, 0, 1, 2]
var markers : Array[Marker2D] = []

var current_spacing := 32.0
var current_hight := 32.0

var side_sign := 1

@export var center : JetBase

@export var height_vertical := 16.0   # 玩家上下飞时
@export var height_horizontal := 64.0 
@export var spacing_height_speed := 4.0

@export var spacing_vertical := 16.0   # 玩家上下飞时
@export var spacing_horizontal := 64.0 # 玩家左右飞时
@export var spacing_lerp_speed := 4.0

@export var runtime_offset := 8.0

@export var mode_focus := true

func _ready() -> void:
	if get_parent() is JetBase:
		center = get_parent()
	
	for i in get_children():
		if i is Marker2D:
			markers.append(i)
	
	for m in get_children():
		var formation_unit = FORMATION_UNITS.instantiate() as FormationUnit
		add_child(formation_unit)
		formation_unit.target = m


func _physics_process(delta: float) -> void:
	update_spacing(delta)
	update_markers()



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		swap_sides()
		mode_focus = !mode_focus


func update_markers():
	for i in range(markers.size()):
		var index = formation_index[i]

		# 高度：只和“距离中心”有关
		var height = -current_hight * abs(index)

		# 排列方向：受左右翻转影响
		var y = index * current_spacing * side_sign

		markers[i].position = Vector2(height, y)

func update_spacing(delta):
	if not center:
		return

	var v := center.velocity
	if v.length() < 0.1:
		return

	var target_spacing: float
	var target_height : float

	# 上下运动为主
	if abs(v.x) < abs(v.y):
	#if mode_focus:
		target_spacing = spacing_vertical
		target_height = height_vertical
	else:
		target_spacing = spacing_horizontal
		target_height = height_horizontal

	target_spacing += randf()  * runtime_offset #运动时的微量水平差距 

	current_hight = lerp(
		current_hight,
		target_height,
		spacing_height_speed * delta
	)

	current_spacing = lerp(
		current_spacing,
		target_spacing,
		spacing_lerp_speed * delta
	)


func swap_sides():
	side_sign *= -1
	update_markers()
