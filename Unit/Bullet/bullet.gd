extends CharacterBody2D
class_name Bullet

var direction : Vector2 = Vector2.RIGHT
@export var speed : float = 1200.0

func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
