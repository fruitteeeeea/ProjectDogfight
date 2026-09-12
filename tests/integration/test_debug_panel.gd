extends "res://tests/integration/test_battle_flow.gd"

class TestWidgets extends RefCounted:
	var pressed := ""
	var disabled := false
	var depth := 0
	func Text(_text: String) -> void:
		pass
	func BeginDisabled(value: bool) -> void:
		disabled = value
		depth += 1
	func EndDisabled() -> void:
		depth -= 1
	func Button(title: String) -> bool:
		return not disabled and title == pressed
	func SameLine() -> void:
		pass

func _ready() -> void:
	await frames()
	var panel := get_node("/root/UniversalDebugPanel")
	var module = panel.get_module(&"dogfight.battle_flow")
	expect(module != null and module.get_category() == &"Programming" and module.get_tab_title() == "Battle Flow", "project module automatically discovered in Programming")
	expect(panel.get_modules_for_category(&"Design").is_empty() and panel.get_modules_for_category(&"Art").is_empty(), "other fixed categories retained")
	expect(panel.process_mode == Node.PROCESS_MODE_ALWAYS and get_node("/root/ImGuiRoot").process_mode == Node.PROCESS_MODE_ALWAYS, "debug backend processes during pause")
	expect(not module.is_available(), "no battle disables buttons")
	for initial_state in [0, 1, 2]:
		for mode in [0, 1, 2]:
			await fresh()
			if initial_state > 0:
				await begin()
			if initial_state == 2:
				manager.pause_battle()
				await get_tree().create_timer(1.1, true, false, true).timeout
			var score := GameStatusServer.your_points
			var kills := GameStatusServer.enemies_destroyed
			expect(module.is_available(), "button enabled in state %d" % initial_state)
			expect(not manager.debug_request_result(99), "invalid result mode rejected")
			var widgets := TestWidgets.new()
			widgets.pressed = ["Game End", "Game Success", "Game Failure"][mode]
			module.draw(widgets, panel)
			expect(manager._debug_result_pending and not module.request_result(mode) and widgets.depth == 0, "draw submits one deferred result with paired ImGui calls")
			await frames(5)
			var result: Dictionary = manager.result_snapshot
			expect(result.points == score and result.kills == kills, "debug result retains current score and kills")
			expect(result.complete == (mode == 1) and result.reason == (0 if mode == 1 else 2), "debug mode %d selects requested result" % mode)
			expect(not module.is_available() and not module.request_result(1), "completed result cannot be overwritten")
			expect(not manager._pause_blur.visible and not manager.mission_panel.mission_timer.paused, "pause background and timer state cleaned before result")
			manager.retry_battle()
			await frames(5)
			game = get_tree().current_scene
			manager = game.get_node("GameManager")
			expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT and is_equal_approx(Engine.time_scale, 1.0), "debug result retries to clean free flight")
	await fresh()
	await begin()
	GameStatusServer.your_points = manager.target_points
	expect(module.request_result(0), "normal debug ending accepts target score")
	await frames(5)
	expect(manager.result_snapshot.complete and manager.result_snapshot.rank == "C", "normal ending uses real success and rank thresholds")
	var retained: Dictionary = manager.result_snapshot.duplicate(true)
	manager.finish_battle(2)
	expect(manager.result_snapshot == retained, "normal end entry cannot replace debug snapshot")
	get_tree().paused = false
	GameStatusServer.manager = null
	game.queue_free()
	await get_tree().create_timer(5.5, true, false, true).timeout
	print("Debug panel tests: %d failure(s)" % failures)
	get_tree().quit(0 if failures == 0 else 1)
