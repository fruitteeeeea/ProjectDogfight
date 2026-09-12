extends Node2D

enum EndReason { COMPLETE, DESTROYED, TIME_UP }
enum DebugResultMode { NORMAL, SUCCESS, FAILURE }
var _debug_result_pending := false
var _debug_result_override := -1
@export var mission_time: float = 60.0
@export var player: Player
var state := GameStatusServer.BattleState.PREPARING
var result_snapshot: Dictionary = {}
var target_points := 2500
var _initialized := false
var _starting_battle := false
var _resume_state := GameStatusServer.BattleState.FREE_FLIGHT
var _initial_enemies: Array[Node] = []
var _ending := false
var _navigation_pending := false
var _loop_audio: Array[Node] = []
var _result_audio_bus := ""
var _result_slowdown: Tween
var _paused_audio: Dictionary = {}
var _bgm_volume_db := 0.0
var _overlay: Control
var _pause_button: Button
var _pause_flash: Tween
var _start_prompt_text: String
var _start_prompt_alignment: int
var _pause_blur: ColorRect
var _pause_panel: Control
var mission_panel: MissionPanel
@onready var result_menu: ResultMenu = $"../GameHUD/ResultMenu"
@onready var ready_to_start: Control = $"../GameHUD/ReadyToStart"
@onready var touch_control: Control = $"../GameHUD/PlayerTouchControl"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameStatusServer.manager = self
	GameStatusServer.reset_game_status()
	GameFeel.cancel_hit_stop()
	get_tree().paused = true
	$"../EnemySpawner/Timer".stop()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy and enemy.get_parent() == get_parent():
			_initial_enemies.append(enemy.duplicate())
			enemy.queue_free()
	await get_tree().process_frame
	mission_panel = player.mission
	target_points = GameStatusServer.rank.keys().min()
	player.player_dead.connect(func(): finish_battle(EndReason.DESTROYED))
	mission_panel.mission_timer.timeout.connect(func(): finish_battle(EndReason.TIME_UP))
	$"../GameHUD".process_mode = Node.PROCESS_MODE_ALWAYS
	result_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
	_initialized = true
	state = GameStatusServer.BattleState.FREE_FLIGHT
	_pause_button.show()
	_set_world_paused(false)

func _build_menu() -> void:
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$"../GameHUD".add_child(_overlay)
	_pause_blur = result_menu.blur_background.duplicate() as ColorRect
	_pause_blur.name = "PauseBlur"
	_pause_blur.material = result_menu.blur_background.material.duplicate()
	_pause_blur.material.set_shader_parameter("blur_amount", 4.0)
	_pause_blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_pause_blur)
	_pause_blur.hide()
	_pause_button = _button("Pause", pause_battle)
	_overlay.add_child(_pause_button)
	_pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_pause_button.offset_left = -230
	_pause_button.offset_right = -30
	_pause_button.offset_top = 48
	_pause_button.offset_bottom = 112
	_start_prompt_text = ready_to_start.get_node("PanelContainer/TapHereToStart/Label").text
	_start_prompt_alignment = ready_to_start.get_node("PanelContainer/TapHereToStart/Label").horizontal_alignment
	ready_to_start.z_index = 1
	_pause_panel = _panel("Paused", [["Continue", resume_battle], ["Retry", retry_battle], ["Main menu", return_to_menu]])
	_pause_panel.get_child(0).get_child(0).hide()
	_pause_panel.hide()
	_pause_button.hide()

func _show_paused_prompt() -> void:
	var panel: Control = ready_to_start.get_node("PanelContainer")
	panel.get_node("BlinkCanvsItem").stop_tween()
	panel.get_node("TapHereToStart/Label").text = "Paused"
	panel.get_node("TapHereToStart/Label").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.modulate.a = 1.0
	ready_to_start.show()
	_pause_flash = create_tween().set_ignore_time_scale(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in range(2):
		_pause_flash.tween_property(panel, "modulate:a", 0.0, 0.1)
		_pause_flash.tween_property(panel, "modulate:a", 1.0, 0.1)

func _restore_start_prompt() -> void:
	if _pause_flash:
		_pause_flash.kill()
	var panel: Control = ready_to_start.get_node("PanelContainer")
	panel.modulate.a = 1.0
	panel.get_node("TapHereToStart/Label").text = _start_prompt_text
	panel.get_node("TapHereToStart/Label").horizontal_alignment = _start_prompt_alignment
	panel.get_node("BlinkCanvsItem").start_tween()
	ready_to_start.visible = state == GameStatusServer.BattleState.FREE_FLIGHT

func _button(title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(200, 64)
	button.pressed.connect(action)
	return button

func _panel(title: String, actions: Array) -> Control:
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	for action in actions:
		box.add_child(_button(action[0], action[1]))
	return panel

func start_battle() -> void:
	if not _initialized or _starting_battle or state != GameStatusServer.BattleState.FREE_FLIGHT:
		return
	_starting_battle = true
	_begin_battle.call_deferred()

func _begin_battle() -> void:
	if not _starting_battle:
		return
	if state != GameStatusServer.BattleState.FREE_FLIGHT:
		_starting_battle = false
		return
	state = GameStatusServer.BattleState.PREPARING
	GameFeel.cancel_hit_stop()
	GameStatusServer.reset_game_status()
	touch_control.reset_touch_input()
	_clear_actions()
	for child in get_parent().get_children():
		if child is Bullet or child is SnakeRocket:
			get_parent().remove_child(child)
			child.queue_free()
	player.reset_for_mission()
	ready_to_start.hide()
	state = GameStatusServer.BattleState.PLAYING
	for enemy in _initial_enemies:
		get_parent().add_child(enemy)
	_initial_enemies.clear()
	$"../EnemySpawner/Timer".start()
	mission_panel.mission_start(mission_time, target_points)
	touch_control.visible = GameStatusServer.is_mobile() or GameStatusServer.current_input_mode == GameStatusServer.InputMode.TOUCH_SCREEN
	_starting_battle = false

func _clear_actions() -> void:
	for action in ["open_fire", "launch_rocket", "burst_speed", "engine", "dodge", "move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)

func is_pointer_over_menu(point: Vector2) -> bool:
	return (_pause_button.visible and _pause_button.get_global_rect().has_point(point)) or (state == GameStatusServer.BattleState.FREE_FLIGHT and ready_to_start.visible and ready_to_start.get_node("PanelContainer").get_global_rect().has_point(point))

func pause_battle() -> void:
	if not GameStatusServer.can_control_player():
		return
	_resume_state = state
	state = GameStatusServer.BattleState.PAUSED
	GameFeel.cancel_hit_stop()
	touch_control.reset_touch_input()
	player.reset_combat_input()
	_clear_actions()
	_set_mission_timers_paused(true)
	_bgm_volume_db = mission_panel.bgm_player.volume_db
	mission_panel.bgm_player.volume_db = _bgm_volume_db + linear_to_db(0.5)
	_result_slowdown = create_tween().set_ignore_time_scale(true)
	_result_slowdown.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_result_slowdown.tween_method(func(value: float): Engine.time_scale = value, 1.0, 0.1, 1.0)
	_result_slowdown.tween_callback(_mute_result_battle_audio)
	_show_paused_prompt()
	_pause_blur.show()
	_pause_panel.show()
	_pause_button.hide()
	_pause_panel.get_child(0).get_child(1).grab_focus()

func resume_battle() -> void:
	if state != GameStatusServer.BattleState.PAUSED:
		return
	_clear_pause_background()
	state = _resume_state
	_restore_start_prompt()
	_pause_panel.hide()
	_pause_blur.hide()
	_pause_button.show()
	_set_world_paused(false)

func _set_mission_timers_paused(paused: bool) -> void:
	mission_panel.mission_timer.paused = paused
	$"../EnemySpawner/Timer".paused = paused
	player.get_node("Weapon/RocketLauncher/ReloadingTimer").paused = paused

func _clear_pause_background() -> void:
	if _result_slowdown:
		_result_slowdown.kill()
	GameFeel.cancel_hit_stop()
	_set_mission_timers_paused(false)
	mission_panel.bgm_player.volume_db = _bgm_volume_db
	if get_tree().node_added.is_connected(_on_result_node_added):
		get_tree().node_added.disconnect(_on_result_node_added)
	for audio in _paused_audio:
		if is_instance_valid(audio):
			audio.bus = _paused_audio[audio][0]
			audio.stream_paused = _paused_audio[audio][1]
	_paused_audio.clear()
	if not _result_audio_bus.is_empty():
		var index := AudioServer.get_bus_index(_result_audio_bus)
		if index >= 0:
			AudioServer.remove_bus(index)
		_result_audio_bus = ""

func _set_world_paused(paused: bool) -> void:
	if paused:
		GameFeel.cancel_hit_stop()
		touch_control.reset_touch_input()
		player.reset_combat_input()
		_clear_actions()
		_loop_audio.clear()
		_pause_audio(get_parent())
	else:
		player.get_node("Weapon/PlayerGun").resume_reload()
		for audio in _loop_audio:
			if is_instance_valid(audio):
				audio.stream_paused = false
		_loop_audio.clear()
	get_tree().paused = paused
	touch_control.visible = not paused and GameStatusServer.can_control_player() and (GameStatusServer.is_mobile() or GameStatusServer.current_input_mode == GameStatusServer.InputMode.TOUCH_SCREEN)

func _pause_audio(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		if node.playing:
			node.stream_paused = true
			_loop_audio.append(node)
	for child in node.get_children():
		_pause_audio(child)

func can_debug_request_result() -> bool:
	return OS.has_feature("editor") and _initialized and not _navigation_pending and not _ending and not _debug_result_pending and state in [GameStatusServer.BattleState.FREE_FLIGHT, GameStatusServer.BattleState.PLAYING, GameStatusServer.BattleState.PAUSED]

func debug_request_result(mode: int) -> bool:
	if not can_debug_request_result() or mode not in DebugResultMode.values():
		return false
	_debug_result_pending = true
	_debug_end_battle.call_deferred(mode)
	return true

func _debug_end_battle(mode: int) -> void:
	if _navigation_pending or _ending:
		return
	if state == GameStatusServer.BattleState.PAUSED:
		_clear_pause_background()
	_debug_result_pending = false
	_debug_result_override = mode
	state = GameStatusServer.BattleState.PLAYING
	ready_to_start.hide()
	finish_battle(EndReason.TIME_UP)

func finish_battle(_reason: EndReason) -> void:
	if _ending:
		return
	if state != GameStatusServer.BattleState.PLAYING:
		return
	_ending = true
	state = GameStatusServer.BattleState.FINISHED
	mission_panel.mission_timer.stop()
	GameFeel.cancel_hit_stop()
	# Resolve after this frame's collision/timer callbacks; death has priority.
	_finalize_result.call_deferred()

func is_resolving_result() -> bool:
	return _ending and result_snapshot.is_empty()

func _finalize_result() -> void:
	var reason := EndReason.DESTROYED if player.is_dead else EndReason.TIME_UP
	var complete := not player.is_dead and GameStatusServer.your_points >= target_points
	if _debug_result_override == DebugResultMode.SUCCESS:
		complete = true
	elif _debug_result_override == DebugResultMode.FAILURE:
		complete = false
		reason = EndReason.TIME_UP
	if complete:
		reason = EndReason.COMPLETE
	var rank := "D"
	var thresholds := GameStatusServer.rank.keys()
	thresholds.sort()
	for threshold in thresholds:
		if GameStatusServer.your_points >= threshold:
			rank = GameStatusServer.rank[threshold]
	result_snapshot = {"complete": complete, "reason": reason, "points": GameStatusServer.your_points, "kills": GameStatusServer.enemies_destroyed, "rank": rank}
	_start_result_background()
	_pause_button.hide()
	_pause_panel.hide()
	_pause_blur.hide()
	result_menu.show_battle_result(result_snapshot.duplicate(true), retry_battle)

func _start_result_background() -> void:
	GameFeel.cancel_hit_stop()
	touch_control.reset_touch_input()
	player.reset_combat_input()
	_clear_actions()
	$"../EnemySpawner/Timer".stop()
	get_tree().paused = false
	_result_slowdown = create_tween().set_ignore_time_scale(true)
	_result_slowdown.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_result_slowdown.tween_method(func(value: float): Engine.time_scale = value, 1.0, 0.1, 1.0)
	_result_slowdown.tween_callback(_mute_result_battle_audio)

func _mute_result_battle_audio() -> void:
	if _navigation_pending or state not in [GameStatusServer.BattleState.FINISHED, GameStatusServer.BattleState.PAUSED]:
		return
	_result_audio_bus = "ResultMuted_" + str(get_instance_id())
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, _result_audio_bus)
	AudioServer.set_bus_mute(index, true)
	_route_result_audio(get_parent())
	get_tree().node_added.connect(_on_result_node_added)

func _is_battle_audio(node: Node) -> bool:
	if not (node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D):
		return false
	return not node.is_in_group("ambient_audio") and node != result_menu.win and node != result_menu.lose and node != mission_panel.bgm_player and node.bus != &"Music"

func _route_result_audio(node: Node) -> void:
	if _is_battle_audio(node):
		if state == GameStatusServer.BattleState.PAUSED:
			_paused_audio[node] = [node.bus, node.stream_paused]
			node.stream_paused = true
		else:
			node.stop()
		node.bus = _result_audio_bus
	for child in node.get_children():
		_route_result_audio(child)

func _on_result_node_added(node: Node) -> void:
	if get_parent().is_ancestor_of(node) and _is_battle_audio(node):
		if state == GameStatusServer.BattleState.PAUSED:
			_paused_audio[node] = [node.bus, node.stream_paused]
		node.bus = _result_audio_bus

func retry_battle() -> void:
	_navigate(true)

func return_to_menu() -> void:
	_navigate(false)

func _navigate(retry: bool) -> void:
	if _navigation_pending:
		return
	_navigation_pending = true
	if state == GameStatusServer.BattleState.PAUSED:
		_clear_pause_background()
	if _result_slowdown:
		_result_slowdown.kill()
	GameFeel.cancel_hit_stop()
	player.reset_combat_input()
	GameStatusServer.manager = null
	GameStatusServer.reset_game_status()
	get_tree().paused = false
	if retry:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://game/ui/menus/main_menu.tscn")

func _input(event: InputEvent) -> void:
	var pointer_down: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	if pointer_down and _initialized and GameStatusServer.can_control_player() and _pause_button.visible and _pause_button.get_global_rect().has_point(event.position):
		get_viewport().set_input_as_handled()
		pause_battle()
		return
	var pause_pressed: bool = (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE) or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
	if pause_pressed and state in [GameStatusServer.BattleState.FREE_FLIGHT, GameStatusServer.BattleState.PLAYING, GameStatusServer.BattleState.PAUSED]:
		if GameStatusServer.can_control_player():
			pause_battle()
		elif state == GameStatusServer.BattleState.PAUSED:
			resume_battle()
		get_viewport().set_input_as_handled()

	if not _initialized or state != GameStatusServer.BattleState.FREE_FLIGHT:
		return
	var pointer_pressed: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	if pointer_pressed and ready_to_start.get_node("PanelContainer").get_global_rect().has_point(event.position):
		start_battle()
		get_viewport().set_input_as_handled()
	elif not (event is InputEventKey and event.echo) and event.is_action_pressed("start_game"):
		start_battle()
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	if _result_slowdown:
		_result_slowdown.kill()
		GameFeel.cancel_hit_stop()
	if not _result_audio_bus.is_empty():
		var index := AudioServer.get_bus_index(_result_audio_bus)
		if index >= 0:
			AudioServer.remove_bus(index)
		GameFeel.cancel_hit_stop()
	for enemy in _initial_enemies:
		if is_instance_valid(enemy):
			enemy.free()
	_initial_enemies.clear()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		pause_battle()
