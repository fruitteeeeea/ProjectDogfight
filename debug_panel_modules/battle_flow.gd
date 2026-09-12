extends DebugPanelModule

func get_module_id() -> StringName:
	return &"dogfight.battle_flow"

func get_category() -> StringName:
	return &"Programming"

func get_tab_title() -> String:
	return "Battle Flow"

func get_order() -> int:
	return 10

func is_available() -> bool:
	return is_instance_valid(GameStatusServer.manager) and GameStatusServer.manager.can_debug_request_result()

func request_result(mode: int) -> bool:
	return is_available() and GameStatusServer.manager.debug_request_result(mode)

func draw(imgui: Object, _panel: Node) -> void:
	imgui.Text("State: %s" % GameStatusServer.BattleState.keys()[GameStatusServer.state])
	imgui.Text("Score: %d | Kills: %d" % [GameStatusServer.your_points, GameStatusServer.enemies_destroyed])
	imgui.BeginDisabled(not is_available())
	if imgui.Button("Game End"):
		request_result(0)
	imgui.SameLine()
	if imgui.Button("Game Success"):
		request_result(1)
	imgui.SameLine()
	if imgui.Button("Game Failure"):
		request_result(2)
	imgui.EndDisabled()
	if not is_available():
		imgui.Text("Available during free flight, battle, or pause in the editor.")
