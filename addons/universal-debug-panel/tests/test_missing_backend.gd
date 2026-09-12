extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var panel := root.get_node("UniversalDebugPanel")
	var status: Dictionary = panel.get_startup_status()
	var ok: bool = not panel.is_ui_enabled() and not status.backend_ready and not status.layout_connected and not status.first_frame_drawn and not status.failure_reason.is_empty()
	print("MISSING BACKEND ", "PASS" if ok else "FAIL", " ", status)
	quit(0 if ok else 1)
