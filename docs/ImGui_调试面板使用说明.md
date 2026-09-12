# ImGui 调试面板

本轮构建：`84e2f60` + R010 / R011 未提交工作区。源项目：`/Users/fruitmilk/Godot Project/GodotEssential`。

## 启用与使用

项目已启用 imgui-godot 6.3.2 和 Universal Debug Panel。使用匹配的 Godot 4.7 / LimboAI 1.8 编辑器打开项目，运行后出现独立的 Debug Panel 窗口。在 Programming > Battle Flow 查看游戏状态、分数和击落数。

| 按钮 | 行为 |
| --- | --- |
| Game End | 按当前分数与玩家存活状态正常结算 |
| Game Success | 强制成功，保留分数与击落数；低分可能显示 D |
| Game Failure | 强制失败，原因显示时间不足，保留当前成绩 |

试飞、战斗及暂停可用；标题、加载、已结算或正在切换场景时禁用。暂停跳转先清理暂停的声音、BGM 音量和渐变，再进入原结算流程。按钮不补分、不修改正式胜负条件；重复点击只接受一次请求。重试返回自由试飞。

## 插件与项目模块规范

- imgui-godot 保留原样；Universal Debug Panel 升级到 1.0.2 开发版本并同步源项目，保留许可证、元数据、模板和 UID。
- 项目模块位于 `debug_panel_modules/battle_flow.gd`，遵守该目录 AGENTS.md。分类及界面使用英文，draw 同步执行，Begin/End 配对，点击提交延迟请求，不逐帧读写文件。
- R011 已将原生控制器信号连接与 NativeWidgets 门面移至插件核心。Battle Flow 只包含业务显示与三个按钮，不连接后端信号、不写私有字段；注销模块不会关闭整个面板。R010 的业务兼容桥接已被此方案取代。
- 调试根节点与原生后端始终处理；点击独立窗口可能触发游戏失焦自动暂停，暂停状态仍可使用调试按钮。
- 管理器只提供编辑器专用 debug_request_result(mode)，不依赖 ImGui 类型；正常导出环境拒绝调试请求。

## 导出与验证

iOS、Android、Web 的 imgui/debug 与 imgui/release 均为 false，显式排除两套 addons、项目模块和本轮调试集成测试。插件保留其导出时移除 Autoload、导出后恢复机制；导出后检查 ImGuiRoot 在 UniversalDebugPanel 前。

Web Debug 已实际导出到 `/private/tmp/dogfight-r010-web/index.html`，导出码 0；枚举 PCK 共 607 个文件，两套 addon 和项目调试模块路径均不存在。未在浏览器运行 Web，也未导出或真机运行 iOS/Android，不能视为发布验收。

Godot 沙箱内编辑器导入/导出有系统证书读取和全局 editor_settings 保存受限错误；Web 导出器还会输出禁用 ImGui GDExtension 的预期提示。图形退出存在既有纹理回收警告，未修改第三方底层渲染。

## 自动与手动检查

自动场景：`tests/integration/test_debug_panel.tscn`，覆盖自动发现、分类、可用状态、三个按钮的 draw 请求、重复保护、成绩与评级、暂停清理、重试。原战斗、摇杆与 HUD 检查继续保留。

最终结果：调试模块 79 项断言通过、战斗流程 104 项断言通过，均为 0 失败、退出码 0；摇杆与 HUD 回归通过，diff 检查通过。图形确认独立窗口、三个固定分类及按钮，点击强制成功后状态 FINISHED、按钮禁用；未完成窗口移动/缩放与全部输入焦点验收。日志位于 `/private/tmp/dogfight-r010-test_debug_panel-output.log`、`/private/tmp/dogfight-r010-test_battle_flow-output.log`、`/private/tmp/dogfight-r010-visual-output.log`。

手动待验收：移动和缩放独立窗口；分别在试飞、战斗、暂停点击三个按钮；检查鼠标点调试窗口不触发游戏射击，键盘与手柄焦点正常；重试恢复声音、BGM 音量、速度和资源。记录构建、设备及系统、步骤和结果，不把自动检查当作手动通过。

## R011 首次显示与诊断

迁移完整两套插件，先启用 ImGui，再启用 Universal Debug Panel；Autoload 保持 ImGuiRoot 在 UniversalDebugPanel 前。图形运行前等待导入完成。无需从 Battle Flow 复制任何后端适配。最小模块模板与诊断说明见 addons/universal-debug-panel/README.md。

get_startup_status() 的 backend_ready / layout_connected / first_frame_drawn 用于区分库加载、信号连接和真正绘制。headless 首帧未绘制正常；图形运行有渲染但三秒未收到布局只警告一次。新增两个插件启动测试；独立窗口焦点可能触发游戏自动暂停，面板继续处理。

R011 结果：源与游戏启动 17 项，含最小模板 18 项；源 Demo/Resource 22 项，编辑器配置 10 项；游戏调试 79 项、战斗 104 项及摇杆/HUD 通过。图形首次导入、空分类、原生完整控件与暂停绘制通过；Web 再次导出 607 项无调试文件、Autoload 恢复。真实点击、移动/缩放与焦点仍未可靠验收，无图形编辑器导入退出崩溃单列失败，其他平台未验收。详见 [R011 验证记录](UniversalDebugPanel_1.0.2_验证记录.md)。
