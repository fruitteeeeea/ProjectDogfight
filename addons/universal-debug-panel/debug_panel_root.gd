extends Node

signal module_registered(module_id: StringName)
signal module_unregistered(module_id: StringName)

const CATEGORIES := [&"Programming", &"Design", &"Art"]
const PROJECT_MODULE_DIRECTORY := "res://debug_panel_modules"

var _imgui: Object
var _imgui_root: Node
var _window_class: Object
var _startup_usec := 0
var _watchdog_warned := false
var _startup := {"backend_ready": false, "layout_connected": false, "first_frame_drawn": false, "failure_reason": "", "layout_frames": 0, "render_frames": 0, "draw_frames": 0}
var _skip_first_layout := true
var _ui_enabled := false
var _modules: Dictionary = {}
var _modules_by_category: Dictionary = {
	&"Programming": [],
	&"Design": [],
	&"Art": [],
}
var _settings_resources: Dictionary = {}


func _ready() -> void:
	if _ui_enabled:
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	_startup_usec = Time.get_ticks_usec()
	if not OS.has_feature("editor"):
		_startup.failure_reason = "Editor runtime required."
		return
	if not Engine.has_singleton("ImGuiGD") or not ClassDB.class_exists("ImGuiWindowClassPtr") or not ClassDB.class_exists("ImGui"):
		_fail_startup("Full native imgui-godot 6.3.2 is required; ImGuiGD, ImGui or ImGuiWindowClassPtr is missing.")
		return
	var backend := get_node_or_null("/root/ImGuiRoot")
	if backend == null:
		_fail_startup("ImGuiRoot must be registered before UniversalDebugPanel.")
		return
	backend.process_mode = Node.PROCESS_MODE_ALWAYS
	for controller in backend.get_children():
		if controller.has_signal("imgui_layout"):
			_imgui_root = controller
			controller.process_mode = Node.PROCESS_MODE_ALWAYS
			break
	if _imgui_root == null:
		_fail_startup("Native ImGui controller with imgui_layout signal was not found under ImGuiRoot.")
		return
	var widgets: Script = load("res://addons/universal-debug-panel/native_widgets.gd")
	if widgets == null or not widgets.can_instantiate():
		_fail_startup("Native widget interface could not be loaded.")
		return
	_imgui = widgets.new()
	_window_class = _imgui.call("create_window_class")
	_startup.backend_ready = true
	if not _imgui_root.is_connected("imgui_layout", _on_imgui_layout):
		_imgui_root.connect("imgui_layout", _on_imgui_layout)
	_startup.layout_connected = true
	_ui_enabled = true
	if DisplayServer.get_name() != "headless" and not RenderingServer.frame_post_draw.is_connected(_on_render_frame):
		RenderingServer.frame_post_draw.connect(_on_render_frame)
	_discover_project_modules(PROJECT_MODULE_DIRECTORY)

func _fail_startup(reason: String) -> void:
	_ui_enabled = false
	_startup.failure_reason = reason
	push_error("Universal Debug Panel: " + reason)

func _on_render_frame() -> void:
	_startup.render_frames += 1

func _process(_delta: float) -> void:
	if _ui_enabled and not _watchdog_warned and _startup.render_frames > 0 and _startup.layout_frames == 0 and Time.get_ticks_usec() - _startup_usec >= 3000000:
		_watchdog_warned = true
		_startup.failure_reason = "No layout callback received after 3 seconds of graphical runtime."
		push_warning("Universal Debug Panel: " + _startup.failure_reason)

func get_startup_status() -> Dictionary:
	return _startup.duplicate(true)

func _exit_tree() -> void:
	_ui_enabled = false
	_startup.layout_connected = false
	if RenderingServer.frame_post_draw.is_connected(_on_render_frame):
		RenderingServer.frame_post_draw.disconnect(_on_render_frame)
	if is_instance_valid(_imgui_root) and _imgui_root.is_connected("imgui_layout", _on_imgui_layout):
		_imgui_root.disconnect("imgui_layout", _on_imgui_layout)
	for module: DebugPanelModule in _modules.values():
		module.shutdown()


func _on_imgui_layout() -> void:
	_startup.layout_frames += 1
	if _skip_first_layout:
		_skip_first_layout = false
		return

	_imgui.call("prepare_window", _window_class)

	if _imgui.call("Begin", "Debug Panel"):
		if _imgui.call("BeginTabBar", "DebugPanelCategories"):
			for category: StringName in CATEGORIES:
				if _imgui.call("BeginTabItem", String(category)):
					_draw_category(category)
					_imgui.call("EndTabItem")
			_imgui.call("EndTabBar")
	_imgui.call("End")
	_startup.first_frame_drawn = true
	_startup.draw_frames += 1


func register_module(module: DebugPanelModule) -> bool:
	if module == null:
		push_error("Universal Debug Panel cannot register a null module.")
		return false

	var module_id := module.get_module_id()
	var category := module.get_category()
	if String(module_id).is_empty():
		push_error("Universal Debug Panel module IDs cannot be empty.")
		return false
	if _modules.has(module_id):
		push_error("Universal Debug Panel module ID '%s' is already registered." % module_id)
		return false
	if category not in CATEGORIES:
		push_error("Universal Debug Panel module '%s' uses unknown category '%s'." % [module_id, category])
		return false
	if module.get_tab_title().is_empty():
		push_error("Universal Debug Panel module '%s' has an empty tab title." % module_id)
		return false

	_modules[module_id] = module
	_modules_by_category[category].append(module)
	_modules_by_category[category].sort_custom(_sort_modules)
	module.initialize(self)
	module_registered.emit(module_id)
	return true


func unregister_module(module_id: StringName) -> bool:
	if not _modules.has(module_id):
		return false

	var module: DebugPanelModule = _modules[module_id]
	module.shutdown()
	_modules_by_category[module.get_category()].erase(module)
	_modules.erase(module_id)
	_settings_resources.erase(module_id)
	module_unregistered.emit(module_id)
	return true


func get_module(module_id: StringName) -> DebugPanelModule:
	return _modules.get(module_id) as DebugPanelModule


func get_modules_for_category(category: StringName) -> Array:
	if not _modules_by_category.has(category):
		return []
	return _modules_by_category[category].duplicate()


func register_settings_resource(module_id: StringName, settings: Resource) -> void:
	if settings == null:
		push_error("Cannot register a null settings resource for module '%s'." % module_id)
		return
	_settings_resources[module_id] = settings


func get_settings_resource(module_id: StringName) -> Resource:
	return _settings_resources.get(module_id) as Resource


func load_settings_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	var settings := ResourceLoader.load(path)
	if settings == null:
		push_error("Could not load settings Resource: %s" % path)
	return settings


func apply_settings_values(settings: Resource, values: Dictionary) -> bool:
	if settings == null:
		push_error("Cannot apply values to a null settings Resource.")
		return false

	var available_properties := {}
	for property: Dictionary in settings.get_property_list():
		available_properties[StringName(property.name)] = true
	for property_name: Variant in values:
		if not available_properties.has(StringName(property_name)):
			push_error("Settings Resource has no property '%s'." % property_name)
			return false

	for property_name: Variant in values:
		settings.set(property_name, values[property_name])
	settings.emit_changed()
	return true


func settings_match_values(settings: Resource, values: Dictionary) -> bool:
	if settings == null:
		return false
	for property_name: Variant in values:
		var current_value: Variant = settings.get(property_name)
		var expected_value: Variant = values[property_name]
		if typeof(current_value) == TYPE_FLOAT and typeof(expected_value) == TYPE_FLOAT:
			if not is_equal_approx(current_value, expected_value):
				return false
		elif current_value != expected_value:
			return false
	return true


func save_settings_resource(settings: Resource, path: String) -> Error:
	if not can_save_project_resources():
		push_error("Debug settings Resources can only be saved from the editor runtime: %s" % path)
		return ERR_UNAUTHORIZED

	var absolute_directory := ProjectSettings.globalize_path(path.get_base_dir())
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		push_error("Could not create settings directory %s: %s" % [path.get_base_dir(), error_string(directory_error)])
		return directory_error

	var save_error := ResourceSaver.save(settings, path)
	if save_error != OK:
		push_error("Could not save settings Resource %s: %s" % [path, error_string(save_error)])
	return save_error


func is_ui_enabled() -> bool:
	return _ui_enabled


func can_save_project_resources() -> bool:
	return OS.has_feature("editor")


func _draw_category(category: StringName) -> void:
	var category_modules: Array = _modules_by_category[category]
	if category_modules.is_empty():
		_imgui.call("TextDisabled", "No %s debug modules registered." % String(category).to_lower())
		return

	if _imgui.call("BeginTabBar", "%sModules" % category):
		for module: DebugPanelModule in category_modules:
			if _imgui.call("BeginTabItem", module.get_tab_title()):
				module.draw(_imgui, self)
				_imgui.call("EndTabItem")
		_imgui.call("EndTabBar")


func _discover_project_modules(directory_path: String) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return

	var entries := directory.get_files()
	entries.sort()
	for filename: String in entries:
		if not filename.ends_with(".gd"):
			continue
		var script_path := directory_path.path_join(filename)
		var module_script: Script = load(script_path)
		if module_script == null:
			push_error("Could not load debug panel module: %s" % script_path)
			continue
		var instance: Variant = module_script.new()
		if not instance is DebugPanelModule:
			push_error("Debug panel module must extend DebugPanelModule: %s" % script_path)
			continue
		register_module(instance)


func _sort_modules(left: DebugPanelModule, right: DebugPanelModule) -> bool:
	if left.get_order() == right.get_order():
		return left.get_tab_title() < right.get_tab_title()
	return left.get_order() < right.get_order()
