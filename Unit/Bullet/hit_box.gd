extends Area2D

@export_enum("Enemy", "Player") var target : String = "Enemy"
@export var bullet : Bullet
@export var damage : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match target:
		"Enemy":
			collision_mask = (1 << 2)
		"Player":
			collision_mask = (1 << 1)  # 第 2 层s


func _on_body_entered(body: Node2D) -> void:
	if body is JetBase:
		body.take_damage(damage)
		bullet.queue_free()
