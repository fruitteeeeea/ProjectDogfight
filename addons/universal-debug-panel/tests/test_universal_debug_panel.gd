extends SceneTree

const DEMO_PATH := "res://Framework/Imgui/Demo/ImguiDemo.tscn"
const DEMO_MODULE_ID := &"godot_essential_print_number_demo"

var failures: Array[String] = []
var _change_count := 0
var checks := 0


class TestModule extends DebugPanelModule:
	var module_id: StringName
	var category: StringName
	var title: String
	var order: int

	func _init(id_value: StringName, category_value: StringName, title_value: String, order_value: int) -> void:
		module_id = id_value
		category = category_value
		title = title_value
		order = order_value

	func get_module_id() -> StringName:
		return module_id

	func get_category() -> StringName:
		return category

	func get_tab_title() -> String:
		return title

	func get_order() -> int:
		return order


class TestSettings extends Resource:
	var value := 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var panel := root.get_node_or_null("UniversalDebugPanel")
	_expect(panel != null, "UniversalDebugPanel autoload is missing")
	if panel == null:
		_finish()
		return

	_test_registration(panel)
	_test_settings(panel)
	await _test_demo_lifecycle(panel)
	_finish()


func _test_registration(panel: Node) -> void:
	var first := TestModule.new(&"test_first", &"Programming", "Zeta", 20)
	var second := TestModule.new(&"test_second", &"Programming", "Alpha", 10)
	_expect(panel.register_module(first), "Valid module must register")
	_expect(not panel.register_module(TestModule.new(&"test_first", &"Programming", "Duplicate", 0)), "Duplicate module ID must be rejected")
	_expect(not panel.register_module(TestModule.new(&"test_invalid", &"Unknown", "Invalid", 0)), "Unknown category must be rejected")
	_expect(panel.register_module(second), "Second valid module must register")
	var modules: Array = panel.get_modules_for_category(&"Programming")
	var first_index := modules.find(second)
	var second_index := modules.find(first)
	_expect(first_index >= 0 and second_index >= 0 and first_index < second_index, "Modules must sort by order")
	_expect(panel.unregister_module(&"test_first"), "Registered module must unregister")
	_expect(panel.unregister_module(&"test_second"), "Second registered module must unregister")
	_expect(not panel.unregister_module(&"test_missing"), "Missing module unregister must return false")


func _test_settings(panel: Node) -> void:
	var settings := TestSettings.new()
	settings.changed.connect(_on_settings_changed)
	_expect(panel.settings_match_values(settings, {"value": 1}), "Initial settings value must match")
	_expect(panel.apply_settings_values(settings, {"value": 3}), "Valid settings update must apply")
	_expect(settings.value == 3 and _change_count == 1, "Apply must update the Resource and emit changed")
	_expect(not panel.apply_settings_values(settings, {"missing": 1}), "Unknown settings property must be rejected")


func _test_demo_lifecycle(panel: Node) -> void:
	if not ResourceLoader.exists(DEMO_PATH):
		print("SKIP: optional GodotEssential Demo is not installed")
		return
	var demo: Node = load(DEMO_PATH).instantiate()
	root.add_child(demo)
	for _frame in 3:
		await process_frame
	_expect(panel.is_ui_enabled(), "Debug panel UI must be enabled in the editor runtime")
	var module: DebugPanelModule = panel.get_module(DEMO_MODULE_ID)
	_expect(module != null, "Demo must register the Print Number module")
	if module != null:
		var settings: Resource = module.call("get_settings")
		var initial_value: int = settings.get("number")
		var next_value := 2 if initial_value != 2 else 3
		module.set_draft_number(next_value)
		_expect(settings.number == initial_value and module.has_unapplied_changes(), "Draft edits must not change the Resource")
		_expect(module.apply_draft(), "Demo draft must apply")
		await process_frame
		_expect(settings.number == next_value, "Applied draft must update the shared Resource")
		_expect(demo.get_node("%AppliedValueLabel").text.ends_with(str(next_value)), "Demo label must reflect the applied value")
		module.reset_draft_to_default()
		_expect(settings.number == next_value, "Reset Defaults must only change the draft")
		module.revert_draft()
		_expect(module.get_draft_number() == next_value and not module.has_unapplied_changes(), "Revert must restore the applied value")
	demo.queue_free()
	await process_frame
	_expect(panel.get_module(DEMO_MODULE_ID) == null, "Demo must unregister its module when closed")


func _on_settings_changed() -> void:
	_change_count += 1


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	print("MODULE/RESOURCE TEST ", "PASS" if failures.is_empty() else "FAIL", " ", checks, " checks")
	for failure in failures:
		push_error(failure)
	quit(1 if not failures.is_empty() else 0)
