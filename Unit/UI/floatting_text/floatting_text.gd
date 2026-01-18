extends AnimatedSprite2D
class_name FloattingText


func _ready() -> void:
	SoundManager.play_sfx("SFXBonus")
	play("default")


func _on_animation_finished() -> void:
	queue_free()
