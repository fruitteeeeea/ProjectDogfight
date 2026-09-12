extends Control
class_name WayPointIcon
@export var target: Node2D
@onready var control: Control = $Control

func _ready() -> void:
	hide()
	update_target_visibility.call_deferred()

func update_target_visibility() -> void:
	if not is_instance_valid(target):
		hide()
		return
	if (target is JetBase and target.is_dead) or (target is SupplyPackage and target.is_picked):
		hide()
		return
	var viewport_rect := get_viewport().get_visible_rect()
	var sprite := target.get_node_or_null("Graphic/Sprite2D") as Sprite2D
	if sprite == null and target is Sprite2D:
		sprite = target
	if sprite:
		var screen_rect: Rect2 = sprite.get_global_transform_with_canvas() * sprite.get_rect()
		visible = not viewport_rect.intersects(screen_rect)
	else:
		visible = not viewport_rect.has_point(target.get_global_transform_with_canvas().origin)

func _physics_process(_delta: float) -> void:
	update_target_visibility()
	if not visible:
		return
	control.position = _get_screen_pos(target)
	control.rotation = _get_rotate_dir()

func _get_screen_pos(tracked: Node2D) -> Vector2:
	var viewport_rect := get_viewport().get_visible_rect()
	var screen_pos := tracked.get_global_transform_with_canvas().origin
	var minimum := viewport_rect.position + Vector2(50, 100)
	var maximum := viewport_rect.end - Vector2(100, 50)
	return get_global_transform_with_canvas().affine_inverse() * screen_pos.clamp(minimum, maximum)

func _get_rotate_dir() -> float:
	var dir := target.get_global_transform_with_canvas().origin - get_viewport().get_visible_rect().get_center()
	return dir.angle() if not dir.is_zero_approx() else 0.0
