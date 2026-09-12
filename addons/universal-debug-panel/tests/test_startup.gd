extends SceneTree

var failures: Array[String] = []
var checks := 0

class ClickWidgets extends RefCounted:
	func Text(_text: String) -> void:
		pass
	func Button(_text: String) -> bool:
		return true

class Module extends DebugPanelModule:
	var initialized := 0
	var stopped := 0
	func get_module_id() -> StringName:
		return &"test.startup"
	func get_category() -> StringName:
		return &"Programming"
	func get_tab_title() -> String:
		return "Startup"
	func initialize(_panel: Node) -> void:
		initialized += 1
	func shutdown() -> void:
		stopped += 1

func _initialize() -> void:
	_run.call_deferred()

func expect(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)

func _run() -> void:
	await process_frame
	var panel := root.get_node("UniversalDebugPanel")
	var status: Dictionary = panel.get_startup_status()
	expect(status.backend_ready, "Native backend ready")
	expect(status.layout_connected, "Native signal connected")
	expect(status.failure_reason.is_empty(), "No startup failure")
	expect(panel.process_mode == Node.PROCESS_MODE_ALWAYS, "Panel always processes")
	var backend := root.get_node("ImGuiRoot")
	expect(backend.process_mode == Node.PROCESS_MODE_ALWAYS, "Backend always processes")
	expect(backend.get_child(0).process_mode == Node.PROCESS_MODE_ALWAYS, "Controller always processes")
	var minimal: DebugPanelModule = panel.get_module(&"example.minimal")
	if minimal != null:
		var previous: int = minimal.get("clicks")
		minimal.draw(ClickWidgets.new(), panel)
		expect(minimal.get("clicks") == previous + 1, "Minimal template click handler")
	var initial_connections := backend.get_child(0).get_signal_connection_list("imgui_layout").size()
	panel.call("_ready")
	expect(backend.get_child(0).get_signal_connection_list("imgui_layout").size() == initial_connections, "Repeated initialization does not reconnect")
	var module := Module.new()
	expect(panel.register_module(module), "Register")
	expect(module.initialized == 1, "Initialize once")
	expect(panel.unregister_module(module.get_module_id()), "Unregister")
	expect(module.stopped == 1, "Shutdown once")
	expect(panel.is_ui_enabled(), "Unregister does not disable panel")
	expect(panel.register_module(module), "Reregister")
	expect(module.initialized == 2, "Reinitialize")
	panel.unregister_module(module.get_module_id())
	expect(module.stopped == 2, "Second shutdown")
	var detached: Node = load("res://addons/universal-debug-panel/debug_panel_root.tscn").instantiate()
	root.add_child(detached)
	var controller := backend.get_child(0)
	var before := controller.get_signal_connection_list("imgui_layout").size()
	expect(before >= 2, "New panel connected")
	detached.queue_free()
	await process_frame
	expect(controller.get_signal_connection_list("imgui_layout").size() == before - 1, "Exit disconnects only own connection")
	print("HEADLESS STARTUP ", "PASS" if failures.is_empty() else "FAIL", " ", checks, " checks ", failures)
	quit(0 if failures.is_empty() else 1)
