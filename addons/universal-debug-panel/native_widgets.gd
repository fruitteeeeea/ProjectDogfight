extends RefCounted
# Object-compatible facade for native imgui-godot 6.3.2 static methods.
func Begin(title: StringName, open: Array = [], flags: int = 0) -> bool:
	return ImGui.Begin(title, open, flags)
func End() -> void:
	ImGui.End()
func BeginTabBar(id: StringName, flags: int = 0) -> bool:
	return ImGui.BeginTabBar(id, flags)
func EndTabBar() -> void:
	ImGui.EndTabBar()
func BeginTabItem(title: StringName, open: Array = [], flags: int = 0) -> bool:
	return ImGui.BeginTabItem(title, open, flags)
func EndTabItem() -> void:
	ImGui.EndTabItem()
func Text(text: String) -> void:
	ImGui.Text(text)
func TextDisabled(text: String) -> void:
	ImGui.TextDisabled(text)
func Button(title: StringName) -> bool:
	return ImGui.Button(title)
func SameLine() -> void:
	ImGui.SameLine()
func BeginDisabled(disabled: bool = true) -> void:
	ImGui.BeginDisabled(disabled)
func EndDisabled() -> void:
	ImGui.EndDisabled()
func Separator() -> void:
	ImGui.Separator()
func SeparatorText(text: String) -> void:
	ImGui.SeparatorText(text)
func SliderFloat(title: StringName, value: Array, minimum: float, maximum: float) -> bool:
	return ImGui.SliderFloat(title, value, minimum, maximum)
func SliderInt(title: StringName, value: Array, minimum: int, maximum: int) -> bool:
	return ImGui.SliderInt(title, value, minimum, maximum)
func BeginChild(id: StringName, size: Vector2 = Vector2.ZERO, child_flags: int = 0, window_flags: int = 0) -> bool:
	return ImGui.BeginChild(id, size, child_flags, window_flags)
func EndChild() -> void:
	ImGui.EndChild()
func GetFrameHeightWithSpacing() -> float:
	return ImGui.GetFrameHeightWithSpacing()
func SetNextItemWidth(width: float) -> void:
	ImGui.SetNextItemWidth(width)

# Load this facade only after the native classes/singleton have been verified.
func create_window_class() -> Object:
	var window_class := ImGuiWindowClassPtr.new()
	window_class.ViewportFlagsOverrideSet = ImGui.ViewportFlags_NoAutoMerge
	var io := ImGui.GetIO()
	io.ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable
	io.IniSavingRate = 1.0
	return window_class

func prepare_window(window_class: ImGuiWindowClassPtr) -> void:
	ImGui.SetNextWindowClass(window_class)
	ImGui.SetNextWindowSize(Vector2(640, 420), ImGui.Cond_FirstUseEver)
