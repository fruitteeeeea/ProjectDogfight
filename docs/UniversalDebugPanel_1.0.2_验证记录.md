# Universal Debug Panel 1.0.2 开发验证记录

基线：GodotEssential `af83009`、ProjectDogfight `84e2f60` + R010/R011 工作区。

日期：2026-09-13；未发布、未提交。源 GodotEssential 修复后同步 ProjectDogfight，第三方 imgui-godot 未修改。源目录额外临时 DLL 不复制。

环境：Apple M1 Pro / macOS 26.5.2 (25F84) / Godot 4.7.limboai+v1.8.0.gha.5b4e0cb0f / 原生 imgui-godot 6.3.2。其他版本、C# 后端、其他桌面平台未验收。

## 自动与图形结果

| 检查 | 实际结果 |
| --- | --- |
| 缺失原生后端隔离项目 | 通过；UI 禁用，明确失败状态，无核心原生类型解析错误 |
| 源与游戏启动、重复初始化、注册/注销、退出断开 | 17 项通过，退出码 0 |
| 最小模块发现与点击处理分支 | 18 项通过，退出码 0；点击为测试控件对象模拟，非真人鼠标验收 |
| 源模块/Resource/Print Number Demo 生命周期 | 22 项通过，退出码 0；非法注册/属性预期错误有明确断言 |
| 隔离图形编辑器启用/禁用/重启用、设置所有权与宿主修改 | 10 项通过，退出码 0 |
| 全新项目仅两套插件、无 .godot：图形首次导入与空面板首次运行 | 退出码 0，backend_ready/layout_connected/first_frame_drawn=true，实际布局与渲染帧 |
| 加入最小模板首次运行 | 独立窗口显示 Programming / Design / Art、Hello Debug Panel 和 Test Button |
| 原生完整控件门面、Print Number Demo、暂停与注销 | 严格图形检查通过，退出码 0 |
| 游戏调试按钮业务/战斗/摇杆/HUD | 79 / 104 项通过，摇杆/HUD 通过，退出码 0 |
| 游戏 Web Debug 包排除与 Autoload 恢复 | 导出 0；607 项 PCK，无插件/原生库/业务模块文件；顺序恢复 |

严格图形入口：`addons/universal-debug-panel/tests/run_graphical_smoke.py ENGINE PROJECT [--empty|--demo]`，15 秒超时失败，脚本错误、原生断言、崩溃、规则失败或非零引擎退出失败。标签布局会保存，因此探针在独立测试窗口调用全部控件，避免用户先前选择的标签跳过测试。

临时项目：`/private/tmp/dogfight-r011-fresh-graph`（全新图形导入）、`/private/tmp/dogfight-r011-minimal`、`/private/tmp/dogfight-r011-config`。首次运行完成后这些目录已有缓存，复现首次迁移需再创建新目录，只复制两套 addons。

日志：`/private/tmp/r011-guard-fresh-import-output.log`、`/private/tmp/r011-guard-fresh-empty-output.log`、`/private/tmp/r011-fresh-graph-import-output.log`、`/private/tmp/r011-fresh-empty-final-output.log`、`/private/tmp/r011-source-tests-final-output.log`、`/private/tmp/r011-source-graph-final2-output.log`、`/private/tmp/r011-editor-config-final-output.log`、`/private/tmp/r011-guard-game-graph-output.log`、`/private/tmp/r011-missing-backend-final-output.log`、`/private/tmp/r011-final-test_debug_panel-output.log`、`/private/tmp/r011-final-test_battle_flow-output.log`、`/private/tmp/r011-web-export-output.log`；PCK 清单 `/private/tmp/r011-web-pck-files.json`。临时日志不属于分发包。

## 异常与尚未验收

- 无图形编辑器首次导入退出时在本构建复现原生 signal 11，退出码 134，该项失败，不记为通过；图形导入正常退出。初次失败与修复后的图形结果分别保留。
- 旧测试的外部 Demo 预加载造成空项目脚本解析错误，已修成可选运行时加载；最终图形首次导入无此错误。
- 初版图形探针因已保存标签未执行控件而失败，已改为独立探针窗口实际调用，最终检查通过。
- 游戏图形退出仍有已知纹理 RID 与 RenderingServer 回收错误；源其他插件报告缺少 Music/SFX 总线警告；无图形沙箱有证书读取错误。当前修复没有改动第三方原生引擎或 ImGui。
- 真实鼠标交互未可靠验收：CUA 点击/拖动没有可靠观察到最小模块计数增加；不能把模拟点击分支或绘制成功当作真实点击通过。多份 Godot 实例与窗口焦点仍需本机人工复核，不将原因定论为工具问题。
- 窗口移动/缩放、三个业务按钮的完整真人流程、键盘/手柄焦点、Web 浏览器运行、iOS/Android 导出与真机体验均未验收。

交互验收请记录构建、设备/系统、用例和步骤：打开独立窗口 → 点击 Test Button 两次，期望 Clicks=2 → 移动/缩放窗口 → 暂停后继续点击 → 注销业务模块，期望空分类仍存在。若点击不响应，保存启动状态与日志，继续定位输入/焦点，不要给业务模块添加后端桥接。

状态：代码与已列自动检查完成，待手动交互与未验证平台验收。首次显示承诺限定完整原生依赖、支持版本与图形编辑器运行环境。
