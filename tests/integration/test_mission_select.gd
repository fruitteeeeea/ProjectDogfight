extends "res://tests/integration/test_battle_flow.gd"

const SELECTOR := "res://game/ui/menus/mission_select.tscn"
const TITLE := "res://game/ui/menus/main_menu.tscn"

func open_scene(path: String) -> Node:
	get_tree().paused = false
	GameFeel.cancel_hit_stop()
	Engine.time_scale = 1.0
	if get_tree().current_scene != self and is_instance_valid(get_tree().current_scene):
		get_tree().current_scene.queue_free()
		await frames()
	GameStatusServer.manager = null
	var scene: Node = load(path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	await frames(5)
	return scene

func node_count(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += node_count(child)
	return count

func action(name: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = name
		event.pressed = pressed
		get_viewport().push_input(event, true)
		await frames()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await frames()
	if "--capture" in OS.get_cmdline_user_args():
		await capture_selection()
		return
	expect(GameStatusServer.selected_mission_id == 1, "first launch selects mission 1")
	var catalog: MissionCatalog = GameStatusServer.mission_catalog
	expect(catalog.missions.size() == 9, "catalog contains nine typed missions")
	for id in range(1, 10):
		var mission := catalog.find_mission(id)
		expect(mission != null and mission.available == (id <= 3), "mission %d availability" % id)
	var title := await open_scene(TITLE)
	await pointer(Vector2(900, 700), true)
	expect(get_tree().current_scene == title, "title animation still gates entry")
	title.get_node("AnimationPlayer").advance(2.1)
	await frames()
	await pointer(Vector2(900, 700), true)
	await frames(5)
	var selector: Control = get_tree().current_scene
	expect(selector.scene_file_path == SELECTOR and GameStatusServer.manager == null, "title touch opens selector without starting battle")
	var row: HBoxContainer = selector.get_node("%MissionButtons")
	expect(row.get_child_count() == 9, "nine buttons pre-instanced in scene")
	for id in range(1, 10):
		var button: Button = row.get_child(id - 1)
		expect(button.scene_file_path.ends_with("mission_button.tscn") and button.disabled == (id > 3) and (id <= 3 or button.focus_mode == Control.FOCUS_NONE), "button %d uses scene and locked focus policy" % id)
	expect(not selector.has_node("Back"), "no return button added")
	var count := node_count(selector)
	for id in [2, 3, 1, 2, 3, 1]:
		await click(row.get_child(id - 1))
		var mission := catalog.find_mission(id)
		expect(GameStatusServer.selected_mission_id == id and selector.get_node("%MissionDetails").get_node("%MissionName").text == mission.display_name, "mouse selects mission %d and updates name" % id)
		expect(selector.get_node("%MissionDetails").get_node("%Objective").text == mission.objective and selector.get_node("%MissionDetails").get_node("%BackgroundStory").text == mission.background_story, "mission %d details match Resource" % id)
	expect(node_count(selector) == count, "selection does not generate UI nodes")
	for id in [0, 4, 9, 10]:
		expect(not GameStatusServer.set_selected_mission(id) and GameStatusServer.selected_mission_id == 1, "invalid or locked mission %d rejected" % id)
	await pointer(row.get_child(3).get_global_rect().get_center(), true)
	expect(GameStatusServer.selected_mission_id == 1, "locked touch does not select")
	await pointer(Vector2(20, 20), true)
	expect(get_tree().current_scene == selector, "blank touch does not start")
	await pointer(row.get_child(2).get_global_rect().get_center(), true)
	expect(GameStatusServer.selected_mission_id == 3 and row.get_child(2).button_pressed, "raw touch selects one mission")
	await action(&"ui_right")
	expect(GameStatusServer.selected_mission_id == 1, "right focus wraps and skips locked slots")
	await action(&"ui_right")
	expect(GameStatusServer.selected_mission_id == 2, "keyboard focus updates mission details")
	await action(&"ui_down")
	expect(get_viewport().gui_get_focus_owner() == selector.get_node("%StartMission"), "down focuses start")
	await action(&"ui_up")
	expect(get_viewport().gui_get_focus_owner() == row.get_child(1), "up returns to selected mission")
	await action(&"ui_accept")
	expect(get_tree().current_scene == selector, "confirm on number selects without starting")
	await action(&"ui_down")
	var echo := InputEventKey.new()
	echo.keycode = KEY_ENTER
	echo.physical_keycode = KEY_ENTER
	echo.pressed = true
	echo.echo = true
	get_viewport().push_input(echo, true)
	await frames()
	expect(get_tree().current_scene == selector, "keyboard repeat cannot start")
	await action(&"ui_accept")
	await frames(5)
	expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT and get_tree().current_scene.get_node("GameManager").mission_id == 2, "focused start enters selected free flight")

	# Invalid selected metadata falls back; no available metadata disables start.
	GameStatusServer.set_selected_mission(3)
	catalog.find_mission(3).available = false
	selector = await open_scene(SELECTOR)
	expect(GameStatusServer.selected_mission_id == 1 and not selector.get_node("%StartMission").disabled, "unavailable selection falls back to mission 1")
	catalog.find_mission(3).available = true
	for id in [1, 2, 3]:
		catalog.find_mission(id).available = false
	selector = await open_scene(SELECTOR)
	expect(selector.get_node("%StartMission").disabled and selector.get_node("%MissionDetails").get_node("%MissionName").text == "Mission unavailable", "no available mission disables preplaced start")
	for id in [1, 2, 3]:
		catalog.find_mission(id).available = true

	for id in [1, 2, 3]:
		GameStatusServer.set_selected_mission(id)
		selector = await open_scene(SELECTOR)
		var start: Button = selector.get_node("%StartMission")
		# A drag from outside cannot reuse an old press to activate Start.
		var down := InputEventScreenTouch.new()
		down.pressed = true
		down.position = Vector2(20, 20)
		get_viewport().push_input(down, true)
		await frames()
		var up := InputEventScreenTouch.new()
		up.position = start.get_global_rect().get_center()
		get_viewport().push_input(up, true)
		await frames()
		expect(get_tree().current_scene == selector, "outside press cannot activate mission %d start" % id)
		var epoch := GameStatusServer.battle_epoch
		if id == 1:
			await click(start)
		elif id == 2:
			await pointer(start.get_global_rect().get_center(), true)
		else:
			selector._request_start()
			selector._request_start()
		await frames(6)
		game = get_tree().current_scene
		manager = game.get_node("GameManager")
		expect(manager.mission_id == id and GameStatusServer.battle_epoch == epoch + 1, "mission %d loads once" % id)
		expect(manager.state == GameStatusServer.BattleState.FREE_FLIGHT and game.get_tree().get_nodes_in_group("enemy").is_empty() and manager.mission_panel.mission_timer.is_stopped(), "mission %d enters enemy-free untimed trial" % id)
		expect(not game.get_node("Player/Weapon/PlayerGun").fire_on, "mission %d start input does not fire" % id)
		expect(manager.mission_time == 60.0 and manager.target_points == 2500 and catalog.find_mission(id).objective == "Earn at least 2,500 points within 60 seconds and survive.", "mission %d text matches real challenge" % id)
		await pointer(manager.ready_to_start.get_node("PanelContainer").get_global_rect().get_center(), true)
		expect(manager.state == GameStatusServer.BattleState.PLAYING and not manager.mission_panel.mission_timer.is_stopped(), "mission %d top prompt starts real challenge" % id)
		GameStatusServer.your_points = 2500
		manager.finish_battle(manager.EndReason.TIME_UP)
		await frames(5)
		expect(manager.result_snapshot.mission_id == id and manager.result_snapshot.complete, "mission %d result records fixed identity" % id)
		await get_tree().create_timer(2.2, true, false, true).timeout
		await pointer(Vector2(20, 20), true)
		await frames(5)
		selector = get_tree().current_scene
		expect(selector.scene_file_path == SELECTOR and GameStatusServer.manager == null and Engine.time_scale == 1.0 and GameStatusServer.selected_mission_id == id, "mission %d result click returns to selection with clean state" % id)
		await click(selector.get_node("%StartMission"))
		await frames(5)
		game = get_tree().current_scene
		manager = game.get_node("GameManager")
		manager.pause_battle()
		var return_button: Button
		for button in manager._pause_panel.find_children("*", "Button", true, false):
			if button.text == "Select mission":
				return_button = button
		expect(return_button != null, "pause menu exposes Select mission action")
		if return_button:
			await click(return_button)
		await frames(5)
		expect(get_tree().current_scene.scene_file_path == SELECTOR and Engine.time_scale == 1.0 and not get_tree().paused, "mission %d pause button returns directly to selection" % id)
		selector = get_tree().current_scene
		expect(selector.scene_file_path == SELECTOR and selector.get_node("%MissionButtons").get_child(id - 1).button_pressed, "mission %d selection persists on return" % id)
	await click(selector.get_node("%MissionButtons").get_child(0))
	expect(GameStatusServer.selected_mission_id == 1, "returned selector can choose another mission")
	get_tree().current_scene.queue_free()
	await get_tree().create_timer(5.5, true, false, true).timeout
	print("Mission selection tests: %d failure(s)" % failures)
	get_tree().quit(1 if failures else 0)

func capture_selection() -> void:
	var selector := await open_scene(SELECTOR)
	for id in [1, 2, 3]:
		selector._select_mission(id)
		selector._selected_button().grab_focus()
		await frames(8)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/private/tmp/r012-select-%d.png" % id)
		print("Captured mission ", id)
	get_tree().quit()
