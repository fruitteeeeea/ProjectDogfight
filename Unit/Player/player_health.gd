extends Control
class_name PlayerHealthHUD

var hit_tween : Tween

@onready var color_rect: ColorRect = $PlayerHitFlash/ColorRect
@onready var player_heart: HBoxContainer = $PlayerHeart/PlayerHeart


func play_hit_flash() -> void:
	if hit_tween:
		hit_tween.kill()
	
	color_rect.modulate.a = .3
	
	hit_tween = create_tween().set_ease(Tween.EASE_OUT)
	hit_tween.tween_property(color_rect, "modulate:a", 0.0, .5)


func update_rocket_count(health : float) -> void:
	var result = floor(health / 10.0)
	# 限制数量范围 0 ~ 子节点数量
	result = clamp(result, 0, player_heart.get_child_count())

	for i in range(player_heart.get_child_count()):
		var child := player_heart.get_child(i)
		if child is TextureRect:
			child.visible = i < result
			await get_tree().create_timer(.05).timeout
