class_name DebugPanelModule
extends RefCounted


func get_module_id() -> StringName:
	return &"module"


func get_category() -> StringName:
	return &"Programming"


func get_tab_title() -> String:
	return "Module"


func get_order() -> int:
	return 0


func initialize(_panel: Node) -> void:
	pass


func draw(_imgui: Object, _panel: Node) -> void:
	pass


func shutdown() -> void:
	pass
