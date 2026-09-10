extends CharacterBody2D

var forward := Vector2.RIGHT


func get_facing() -> float:
	return signf(forward.x)
