extends Node2D

@export var SupplyScene : PackedScene
@export var FloattingText : PackedScene


func spwan_supply() -> void:
	pass


func spwan_flotting_text(pos : Vector2) -> void:
	var floatting_text = FloattingText.instantiate() as FloattingText
	get_tree().current_scene.add_child(floatting_text)
	floatting_text.global_position = pos
