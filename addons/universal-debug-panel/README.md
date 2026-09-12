# Universal Debug Panel

基于 `imgui-godot` 的模块化 Godot 编辑器运行时调试面板。插件提供固定的 `Programming`、`Design`、`Art` 分类、模块生命周期、自动发现，以及类型化 Resource 的 Draft / Apply / Save 工作流；插件核心不包含项目业务模块。

## 安装

1. 安装并启用完整的 `addons/imgui-godot` 6.3.2。
2. 复制 `addons/universal-debug-panel`。
3. 在 Project Settings > Plugins 中启用 Universal Debug Panel。
4. 可选：在 `res://debug_panel_modules` 根目录放置项目模块。插件启动时会按文件名发现 `.gd` 文件。

启用后，插件注册 `UniversalDebugPanel` Autoload，并将 `display/window/subwindows/embed_subwindows` 设为 `false`，让 ImGui Viewport 使用独立原生窗口。面板只在编辑器中运行项目时启用；Debug 与 Release 导出时，插件会暂时移除 Autoload、排除自身文件，并在导出结束后恢复编辑器配置。

## 模块接口

模块继承 `DebugPanelModule`，并实现：

```gdscript
func get_module_id() -> StringName
func get_category() -> StringName # Programming / Design / Art
func get_tab_title() -> String
func get_order() -> int
func initialize(panel: Node) -> void
func draw(imgui: Object, panel: Node) -> void
func shutdown() -> void
```

运行时也可以按场景注册模块：

```gdscript
var module := MyDebugModule.new()
UniversalDebugPanel.register_module(module)
# 场景退出时：
UniversalDebugPanel.unregister_module(module.get_module_id())
```

模块 ID 必须稳定且全局唯一。分类只能使用三个固定值。标签和面板 UI 使用英文；`draw()` 必须同步执行，且所有 ImGui `Begin...` 都要与对应 `End...` 配对。

## Settings Resource 工作流

插件提供：

- `load_settings_resource(path)` / `register_settings_resource(id, resource)` / `get_settings_resource(id)`
- `apply_settings_values(resource, values)`：更新同一个 Resource 并调用 `emit_changed()`
- `settings_match_values(resource, values)`
- `save_settings_resource(resource, path)`：只允许编辑器运行环境写入 `res://`
- `can_save_project_resources()` / `is_ui_enabled()`

推荐的数据流是：控件先编辑单元素数组中的 Draft；Apply 更新 Resource；消费节点监听 `changed`；Save 只保存已经 Apply 的值。通用起点见 `templates/module_template.gd.txt` 与 `templates/settings_template.gd.txt`。

GodotEssential 的完整 Print Number 示例位于 `Framework/Imgui/Demo`，它会随演示场景注册和注销，不属于插件内置功能。

## 验收要点

- 三个顶层分类始终存在，空分类显示英文占位。
- 拒绝空 ID、重复 ID、非法分类与空标题。
- Draft 不提前影响正式值，Apply 会触发 Resource 的 `changed`。
- 未 Apply 时不能 Save；导出运行环境不能写 `res://`。
- 不在 `draw()` 中加载资源、写盘或执行异步操作。

## 分发与版本信息

复制整个 `addons/universal-debug-panel` 目录，在项目设置的插件页启用。 依赖与限制见本目录元数据；版本历史见 CHANGELOG.md。未发布开发版本不填写正式发布日期。

## 1.0.2 首次迁移检查

完整复制两套 addons（包括原生库、许可证、UID、元数据），不要复制 .godot 缓存。原生库必须与当前操作系统/架构匹配；本轮支持范围为 Godot 4.7 / LimboAI 1.8 与原生 imgui-godot 6.3.2，C# 后端及其他版本未验收。先启用 ImGui，再启用 Universal Debug Panel，等待首次导入完成。Autoload 的 ImGuiRoot 必须在 UniversalDebugPanel 前；跨项目配置优先使用 res://addons/... 明确路径，而不是依赖缓存中的 UID。

从图形编辑器运行项目即可出现独立 Debug Panel，Programming / Design / Art 空分类也显示占位文字。无需业务模块连接信号、创建 NativeWidgets 或写插件私有字段。核心直接监听原生子控制器，而不是 ImGuiRoot 脚本上的同名信号；传入 draw 的对象是核心控件门面，不是 ImGuiGD 管理单例。

最小验证：将 templates/minimal_module.gd.txt 复制为 res://debug_panel_modules/minimal_module.gd，重新运行，在 Programming > Hello Debug Panel 点击 Test Button，Clicks 增加。资源编辑继续使用 module_template.gd.txt 与 settings_template.gd.txt。

### 启动诊断

读取 UniversalDebugPanel.get_startup_status()：backend_ready、layout_connected、first_frame_drawn、failure_reason，以及 layout_frames / render_frames / draw_frames。headless 中首帧和窗口不要求绘制；不能凭 headless 通过宣称窗口可见。

- backend_ready=false：检查完整原生库、引擎版本、ImGuiRoot Autoload 及顺序。缺少后端时核心禁用 UI，并输出原因；完全无法加载 GDExtension 时还应先处理引擎的原生类型/脚本加载错误。
- layout_connected=false：检查 ImGuiRoot 下实际原生控制器是否存在并提供 imgui_layout。
- 有图形渲染但三秒没有布局：核心仅警告一次。检查后端初始化与运行窗口；不要在业务模块添加桥接。
- first_frame_drawn=true 但看不到：检查独立窗口位置与 ImGui 保存的布局；调试面板不是游戏内 HUD。可退出后备份/移除用户目录中的 ImGui 布局配置再试。

面板与后端默认 PROCESS_MODE_ALWAYS。启用设置 embed_subwindows=false；禁用仅恢复插件拥有且当前仍为 false 的设置，宿主再次更改后保留宿主值。关闭编辑器不移除 Autoload；导出后的恢复机制保持不变。

### 可复现检查

使用匹配引擎运行：

```sh
godot --headless --path PROJECT --script addons/universal-debug-panel/tests/test_startup.gd
godot --path PROJECT addons/universal-debug-panel/tests/graphical_startup.tscn -- --empty
godot --path PROJECT addons/universal-debug-panel/tests/graphical_startup.tscn
```

图形检查约四秒退出，输出 PASS/FAIL 与状态，失败为非零退出码；第二种运行实际调用模板/Demo 所需原生控件并检查暂停继续绘制、注销不关闭面板。外部测试流程还必须将 SCRIPT ERROR、引擎崩溃和超时视为失败。窗口移动/缩放与鼠标焦点需要另行人工验收。

导出时宿主应显式排除 addons/imgui-godot/*、addons/universal-debug-panel/* 和 debug_panel_modules/*，并按目标设置 imgui/debug=false、imgui/release=false。检查实际 PCK（包括 .godot/exported 编译路径），确认没有调试插件/模块；再次确认编辑器 Autoload 恢复。

严格图形检查可运行 `python3 tests/run_graphical_smoke.py ENGINE PROJECT [--empty|--demo]`。`--demo` 仅用于包含 GodotEssential Demo 的源项目；通用模块/资源测试缺少 Demo 时跳过该分支，不再预加载不存在的资源。编辑器启停探针见 tests/editor_configuration.gd.txt，仅复制到一次性临时项目的 EditorPlugin 中运行，不能在真实项目测试时改写宿主配置。

核心不预加载或直接引用原生类型：先检查 ImGuiGD / ImGui / ImGuiWindowClassPtr，再动态加载控件门面，缺少后端时仍可读取明确失败状态。缺失后端测试 tests/test_missing_backend.gd 仅用于不装 ImGui 原生扩展的隔离项目，保留 DebugPanelModule 类注册即可；期望 UI 禁用而非原生类型解析中断。
