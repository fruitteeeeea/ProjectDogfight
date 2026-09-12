extends Node

var panel: Node
var started := 0
var paused_at := 0
var failures: Array[String] = []
var controller: Node
var demo: Node
var finished := false
var probe: Probe

class Probe extends DebugPanelModule:
	var frames := 0
	var demo_module: DebugPanelModule
	func get_module_id() -> StringName:
		return &"test.native_widgets"
	func get_category() -> StringName:
		return &"Programming"
	func get_tab_title() -> String:
		return "Native Widgets"
	func get_order() -> int:
		return -100
	func draw(ui: Object, _panel: Node) -> void:
		frames += 1
		if demo_module != null:
			demo_module.draw(ui, _panel)
		ui.Text("Native widget smoke test")
		ui.call("TextDisabled", "Disabled text")
		ui.SetNextItemWidth(120.0)
		ui.SliderFloat("Float", [0.5], 0.0, 1.0)
		ui.call("SliderInt", "Integer", [2], 0, 5)
		ui.Separator()
		ui.SeparatorText("Layout")
		ui.BeginDisabled()
		ui.Button("Disabled Button")
		ui.SameLine()
		ui.EndDisabled()
		ui.GetFrameHeightWithSpacing()
		ui.BeginChild("Child", Vector2(180, 60))
		ui.Text("Child text")
		ui.EndChild()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	started = Time.get_ticks_msec()
	panel = get_node_or_null("/root/UniversalDebugPanel")
	if "--demo" in OS.get_cmdline_user_args():
		demo = load("res://Framework/Imgui/Demo/ImguiDemo.tscn").instantiate()
		add_child(demo)
	if panel == null:
		push_error("FAIL: panel missing")
		get_tree().quit(1)

func _process(_delta: float) -> void:
	if panel == null or finished:
		return
	var elapsed := Time.get_ticks_msec() - started
	if elapsed >= 1500 and probe == null and not "--empty" in OS.get_cmdline_user_args():
		probe = Probe.new()
		if demo != null:
			probe.demo_module = panel.get_module(&"godot_essential_print_number_demo")
		panel.register_module(probe)
		controller = get_node("/root/ImGuiRoot").get_child(0)
		controller.imgui_layout.connect(_draw_probe)
	if elapsed >= 2500 and paused_at == 0:
		paused_at = panel.get_startup_status().draw_frames
		get_tree().paused = true
	if elapsed < 4000:
		return
	finished = true
	var status: Dictionary = panel.get_startup_status()
	for key in ["backend_ready", "layout_connected", "first_frame_drawn"]:
		if not status[key]:
			failures.append(key)
	if status.draw_frames <= paused_at:
		failures.append("Panel stopped drawing while tree paused")
	if not status.failure_reason.is_empty():
		failures.append(status.failure_reason)
	if probe != null:
		if demo != null and probe.demo_module == null:
			failures.append("Demo module unavailable")
		if probe.frames == 0:
			failures.append("Native widgets not exercised")
		panel.unregister_module(probe.get_module_id())
		if not panel.is_ui_enabled():
			failures.append("Unregister disabled panel")
	print("GRAPHICAL STARTUP ", "PASS" if failures.is_empty() else "FAIL", " ", status, " ", failures)
	get_tree().paused = false
	if controller != null and controller.imgui_layout.is_connected(_draw_probe):
		controller.imgui_layout.disconnect(_draw_probe)
	panel.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)

func _draw_probe() -> void:
	if finished:
		return
	var ui: Object = load("res://addons/universal-debug-panel/native_widgets.gd").new()
	if ui.Begin("Widget Smoke"):
		probe.draw(ui, panel)
	ui.End()
