extends AnimatedSprite2D
class_name FloattingText

@onready var sfx_bonus: AudioStreamPlayer = $SFXBonus


func _ready() -> void:
	sfx_bonus.play()
	play("default")


func _on_animation_finished() -> void:
	queue_free()
