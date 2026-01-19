extends Control

@onready var gamepad_icon_rect: TextureRect = $GamepadIconRect
@onready var keyboard_icon_rect: TextureRect = $KeyboardIconRect


func _ready() -> void:
	GameStatusServer.change_input_device.connect(_change_display_prompt)


func _change_display_prompt(input_mode : GameStatusServer.InputMode) -> void:
	match input_mode:
		GameStatusServer.InputMode.TOUCH_SCREEN:
			gamepad_icon_rect.show()
			keyboard_icon_rect.hide()
		GameStatusServer.InputMode.GAMEPAD:
			gamepad_icon_rect.show()
			keyboard_icon_rect.hide()
		GameStatusServer.InputMode.KEYBOARD:
			gamepad_icon_rect.hide()
			keyboard_icon_rect.show()
