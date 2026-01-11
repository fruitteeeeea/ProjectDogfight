extends AnimatedSprite2D


func _on_animation_finished() -> void:
	queue_free()


func _on_draw() -> void:
	play("default")
