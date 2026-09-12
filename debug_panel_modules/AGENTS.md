# Universal Debug Panel module rules

- Add project-specific features as new `.gd` modules in this directory. Do not modify the three root categories or addon core for ordinary features.
- Every module must extend `DebugPanelModule`, use a stable unique `StringName` ID, return exactly `Programming`, `Design`, or `Art`, and use English UI text.
- Keep `draw()` synchronous. Never use `await`, perform disk I/O every frame, or leave an ImGui `Begin...` call without its matching `End...` call.
- Use one-element arrays for editable ImGui values. Use stable widget labels/IDs and avoid a full CJK font unless the project explicitly requires it.
- Formal game parameters belong in a typed Resource. Draft edits stay in the module; Apply writes the Resource and calls `emit_changed()`; Save uses `panel.save_settings_resource()` and is editor-only.
- Game nodes consume the same Resource and refresh in `_ready()` and on the Resource `changed` signal.
- Validate missing resources, invalid ranges, duplicate IDs, and save errors. Exported builds must continue using packaged Resources even though the panel UI is absent.

Start from the templates in `res://addons/universal-debug-panel/templates`.

- Backend integration belongs exclusively to Universal Debug Panel. Business modules must not bridge imgui_layout, create native widget adapters, set backend process modes, or access/write addon private fields.
