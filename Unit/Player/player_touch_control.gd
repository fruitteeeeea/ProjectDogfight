extends Control


func _ready() -> void:
	GameStatusServer.change_input_device.connect(_change_display)


func _change_display(mode : GameStatusServer.InputMode) -> void:
	if mode == GameStatusServer.InputMode.TOUCH_SCREEN:
		show()
	else :
		hide()
