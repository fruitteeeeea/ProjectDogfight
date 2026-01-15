extends Control
class_name RocketSlot

@onready var h_box_container: HBoxContainer = $HBoxContainer


func update_rocket_count(nb: int) -> void:
	# 限制数量范围 0 ~ 子节点数量
	nb = clamp(nb, 0, h_box_container.get_child_count())

	for i in range(h_box_container.get_child_count()):
		var child := h_box_container.get_child(i)
		if child is TextureRect:
			child.visible = i < nb
			await get_tree().create_timer(.05).timeout
