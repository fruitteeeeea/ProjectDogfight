@tool
extends EditorPlugin

const AUTOLOAD_NAME := "UniversalDebugPanel"
const AUTOLOAD_PATH := "res://addons/universal-debug-panel/debug_panel_root.tscn"

const OWNER_KEY := "essential_plugins/universal_debug_panel/owns_autoload"

const WINDOW_KEY := "display/window/subwindows/embed_subwindows"
const WINDOW_OWNER_KEY := "essential_plugins/universal_debug_panel/owns_window_setting"
const WINDOW_PREVIOUS_KEY := "essential_plugins/universal_debug_panel/previous_window_setting"

var _exporter: DebugPanelExporter


func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/ImGuiRoot"):
		push_error("Universal Debug Panel requires the full imgui-godot plugin to be enabled first.")

	_ensure_autoload()
	_ensure_window_setting()

	_exporter = DebugPanelExporter.new()
	_exporter.plugin = self
	add_export_plugin(_exporter)


func _exit_tree() -> void:
	if _exporter != null:
		remove_export_plugin(_exporter)
		_exporter = null


func _enable_plugin() -> void:
	_ensure_autoload()
	_ensure_window_setting()

func _ensure_autoload() -> void:
	var key := "autoload/" + AUTOLOAD_NAME
	if ProjectSettings.has_setting(key):
		var existing := _registered_path(key)
		if existing != AUTOLOAD_PATH:
			push_error("Universal Debug Panel: Autoload name conflict: " + AUTOLOAD_NAME)
		return
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	ProjectSettings.set_setting(OWNER_KEY, true)
	ProjectSettings.save()

func _ensure_window_setting() -> void:
	if not bool(ProjectSettings.get_setting(WINDOW_KEY, true)):
		return
	ProjectSettings.set_setting(WINDOW_PREVIOUS_KEY, {"existed": ProjectSettings.has_setting(WINDOW_KEY), "value": ProjectSettings.get_setting(WINDOW_KEY, true)})
	ProjectSettings.set_setting(WINDOW_OWNER_KEY, true)
	ProjectSettings.set_setting(WINDOW_KEY, false)
	ProjectSettings.save()

func _restore_window_setting() -> void:
	if bool(ProjectSettings.get_setting(WINDOW_OWNER_KEY, false)) and not bool(ProjectSettings.get_setting(WINDOW_KEY, true)):
		var previous: Dictionary = ProjectSettings.get_setting(WINDOW_PREVIOUS_KEY, {})
		ProjectSettings.set_setting(WINDOW_KEY, previous.get("value", true) if previous.get("existed", true) else null)
	ProjectSettings.set_setting(WINDOW_OWNER_KEY, null)
	ProjectSettings.set_setting(WINDOW_PREVIOUS_KEY, null)

func _disable_plugin() -> void:
	_restore_window_setting()
	var key := "autoload/" + AUTOLOAD_NAME
	if bool(ProjectSettings.get_setting(OWNER_KEY, false)):
		if _registered_path(key) == AUTOLOAD_PATH:
			remove_autoload_singleton(AUTOLOAD_NAME)
	ProjectSettings.set_setting(OWNER_KEY, null)
	ProjectSettings.save()


class DebugPanelExporter extends EditorExportPlugin:
	var plugin: EditorPlugin
	var _autoload_was_registered := false


	func _get_name() -> String:
		return "UniversalDebugPanel"


	func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
		_autoload_was_registered = ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME)
		if _autoload_was_registered:
			plugin.remove_autoload_singleton(AUTOLOAD_NAME)


	func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
		if path.begins_with("res://addons/universal-debug-panel/"):
			skip()


	func _export_end() -> void:
		if _autoload_was_registered and not ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME):
			plugin.add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
		_autoload_was_registered = false


func _registered_path(key: String) -> String:
	var path := str(ProjectSettings.get_setting(key, "")).trim_prefix("*")
	if path.begins_with("uid://"):
		return ResourceUID.get_id_path(ResourceUID.text_to_id(path))
	return path
