extends CanvasLayer

@onready var result_menu: ResultMenu = $ResultMenu

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		result_menu.show_result(false)
