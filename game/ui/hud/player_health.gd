extends Control
class_name PlayerHealthHUD

var hit_tween : Tween

@export var player_damage_component : PlayerDamageComponent

@onready var color_rect: ColorRect = $PlayerHitFlash/ColorRect
@onready var player_heart: HBoxContainer = $PlayerHeart/PlayerHeart

var cache_health : float

func _ready() -> void:
	player_damage_component.health_change.connect(_health_change)
	reset_display()


func _health_change(health : float) -> void:
	if health < cache_health: #扣血了 
		play_hit_flash()

	cache_health = health
	update_health_count(health)


func play_hit_flash() -> void:
	if hit_tween:
		hit_tween.kill()
	
	color_rect.modulate.a = .3
	
	hit_tween = create_tween().set_ease(Tween.EASE_OUT)
	hit_tween.tween_property(color_rect, "modulate:a", 0.0, .5)


func update_health_count(health : float) -> void:
	var result = floor(health / 10.0)
	# 限制数量范围 0 ~ 子节点数量
	result = clamp(result, 0, player_heart.get_child_count())

	for i in range(player_heart.get_child_count()):
		var child := player_heart.get_child(i)
		if child is TextureRect:
			child.visible = i < result

func reset_display() -> void:
	if hit_tween:
		hit_tween.kill()
	color_rect.modulate.a = 0.0
	cache_health = player_damage_component.health
	update_health_count(cache_health)
