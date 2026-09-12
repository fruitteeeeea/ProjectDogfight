extends Control

const BATTLE_SCENE := "res://game/core/main_game.tscn"

@export_range(0, 200) var safe_margin: int = 64
@onready var safe_area: MarginContainer = %SafeArea
@onready var mission_buttons: HBoxContainer = %MissionButtons
@onready var details: PanelContainer = %MissionDetails
@onready var start_button: Button = %StartMission

var _entering := false
var _touch_targets: Dictionary = {}

func _ready() -> void:
	get_viewport().size_changed.connect(_update_safe_area)
	_update_safe_area()
	for button: Button in mission_buttons.get_children():
		var id: int = button.get_meta("mission_id")
		var mission := GameStatusServer.mission_catalog.find_mission(id)
		button.disabled = mission == null or not mission.available
		button.focus_mode = Control.FOCUS_NONE if button.disabled else Control.FOCUS_ALL
		button.pressed.connect(_select_mission.bind(id))
		button.focus_entered.connect(_select_mission.bind(id))
	start_button.pressed.connect(_request_start)
	if GameStatusServer.get_selected_mission() == null:
		GameStatusServer.set_selected_mission(1)
	_refresh_selection()
	_update_focus_paths()
	var selected := _selected_button()
	if selected != null:
		selected.grab_focus()

func _select_mission(id: int) -> void:
	if _entering or not GameStatusServer.set_selected_mission(id):
		return
	_refresh_selection()
	_update_focus_paths()

func _refresh_selection() -> void:
	var mission := GameStatusServer.get_selected_mission()
	details.display_mission(mission)
	start_button.disabled = mission == null
	start_button.focus_mode = Control.FOCUS_NONE if start_button.disabled else Control.FOCUS_ALL
	for button: Button in mission_buttons.get_children():
		button.set_pressed_no_signal(mission != null and button.get_meta("mission_id") == mission.mission_id)

func _selected_button() -> Button:
	for button: Button in mission_buttons.get_children():
		if not button.disabled and button.get_meta("mission_id") == GameStatusServer.selected_mission_id:
			return button
	return null

func _update_focus_paths() -> void:
	var enabled: Array[Button] = []
	for button: Button in mission_buttons.get_children():
		if not button.disabled:
			enabled.append(button)
	for index in enabled.size():
		var button := enabled[index]
		button.focus_neighbor_left = button.get_path_to(enabled[(index - 1 + enabled.size()) % enabled.size()])
		button.focus_neighbor_right = button.get_path_to(enabled[(index + 1) % enabled.size()])
		button.focus_neighbor_top = button.get_path_to(button)
		button.focus_neighbor_bottom = button.get_path_to(start_button)
		button.focus_next = button.get_path_to(enabled[index + 1] if index + 1 < enabled.size() else start_button)
		button.focus_previous = button.get_path_to(enabled[index - 1] if index > 0 else start_button)
	var selected := _selected_button()
	if selected != null:
		start_button.focus_neighbor_top = start_button.get_path_to(selected)
		start_button.focus_neighbor_bottom = start_button.get_path_to(start_button)
		start_button.focus_neighbor_left = start_button.get_path_to(start_button)
		start_button.focus_neighbor_right = start_button.get_path_to(start_button)
		start_button.focus_next = start_button.get_path_to(enabled[0])
		start_button.focus_previous = start_button.get_path_to(enabled[-1])

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo and event.is_action_pressed("ui_accept", true):
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenDrag:
		if _touch_targets.has(event.index):
			get_viewport().set_input_as_handled()
		return
	if not event is InputEventScreenTouch:
		return
	# Consume raw touch so the GUI never also activates the same button.
	get_viewport().set_input_as_handled()
	if _entering:
		return
	if event.pressed:
		_touch_targets[event.index] = _button_at(event.position)
		return
	var pressed_button: Button = _touch_targets.get(event.index)
	_touch_targets.erase(event.index)
	if event.canceled or pressed_button == null or pressed_button != _button_at(event.position):
		return
	if pressed_button == start_button:
		_request_start()
	else:
		_select_mission(pressed_button.get_meta("mission_id"))
		pressed_button.grab_focus()

func _button_at(point: Vector2) -> Button:
	if not start_button.disabled and start_button.is_visible_in_tree() and start_button.get_global_rect().has_point(point):
		return start_button
	for button: Button in mission_buttons.get_children():
		if not button.disabled and button.is_visible_in_tree() and button.get_global_rect().has_point(point):
			return button
	return null

func _request_start() -> void:
	if _entering or GameStatusServer.get_selected_mission() == null:
		return
	_entering = true
	_touch_targets.clear()
	start_button.disabled = true
	get_viewport().set_input_as_handled()
	_enter_battle.call_deferred()

func _enter_battle() -> void:
	var error := get_tree().change_scene_to_file(BATTLE_SCENE)
	if error != OK:
		_entering = false
		_refresh_selection()
		push_error("Could not enter battle: " + error_string(error))

func _update_safe_area() -> void:
	var insets := Vector4.ZERO
	if OS.has_feature("mobile"):
		var window_size := DisplayServer.window_get_size()
		var window_position := DisplayServer.window_get_position()
		var safe := DisplayServer.get_display_safe_area().intersection(Rect2i(window_position, window_size))
		if safe.has_area() and window_size.x > 0 and window_size.y > 0:
			var ratio := get_viewport_rect().size / Vector2(window_size)
			insets = Vector4((safe.position.x - window_position.x) * ratio.x, (safe.position.y - window_position.y) * ratio.y, (window_position.x + window_size.x - safe.end.x) * ratio.x, (window_position.y + window_size.y - safe.end.y) * ratio.y)
	safe_area.add_theme_constant_override("margin_left", safe_margin + ceili(insets.x))
	safe_area.add_theme_constant_override("margin_top", safe_margin + ceili(insets.y))
	safe_area.add_theme_constant_override("margin_right", safe_margin + ceili(insets.z))
	safe_area.add_theme_constant_override("margin_bottom", safe_margin + ceili(insets.w))
