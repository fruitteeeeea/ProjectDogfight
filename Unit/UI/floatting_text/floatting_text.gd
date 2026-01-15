extends AnimatedSprite2D
class_name FloattingText


func _on_draw() -> void:
	play("default")


func _on_animation_finished() -> void:
	queue_free()
