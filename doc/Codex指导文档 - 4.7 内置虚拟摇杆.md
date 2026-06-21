# Godot 4.7 内置 `VirtualJoystick` 使用与迁移规范

Godot 4.7 已提供官方 `VirtualJoystick` 节点。它继承自 `Control`，负责把触摸拖动转换为四个 InputMap 动作：上、下、左、右；角色逻辑应继续从 `Input.get_vector()` 或 `Input.get_axis()` 读取输入，而不是直接读取摇杆节点的自定义向量。这样键鼠、手柄、触摸会共用同一套移动代码。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))

这份规范的目标是：**所有项目彻底删除旧虚拟摇杆代码、场景、资源、输入桥接与兼容层，只保留 Godot 4.7 官方 `VirtualJoystick`。**

---

## 1. 最终输入架构

```text
键盘 / 手柄 / 官方 VirtualJoystick
                ↓
          InputMap 动作
                ↓
      Input.get_vector(...) / Input.get_axis(...)
                ↓
            玩家移动逻辑
```

`VirtualJoystick` 在内部会按摇杆方向调用对应的 Input Action，并带入 0~1 的模拟量强度。因此，移动脚本无需知道当前输入来自触屏、键盘还是手柄。([GitHub](https://raw.githubusercontent.com/godotengine/godot/master/scene/gui/virtual_joystick.cpp "raw.githubusercontent.com"))

### 统一 InputMap 动作

所有项目统一使用以下四个动作，不使用 `ui_left`、`ui_right` 等 UI 默认动作：

```text
move_left
move_right
move_up
move_down
```

建议绑定：

|动作|键盘|手柄|
|---|---|---|
|`move_left`|A / Left|左摇杆左|
|`move_right`|D / Right|左摇杆右|
|`move_up`|W / Up|左摇杆上|
|`move_down`|S / Down|左摇杆下|

不要继续保留这类旧动作：

```text
touch_left
touch_right
touch_up
touch_down
mobile_move_left
virtual_joystick_left
joystick_move_x
joystick_move_y
```

旧动作全部迁移完成后，从 Project Settings → Input Map 删除。

---

## 2. 官方节点的最小配置

场景结构建议：

```text
CanvasLayer
└── MobileHUD (Control，全屏)
    ├── MoveJoystick (VirtualJoystick，左下触摸区域)
    ├── AttackButton
    ├── DodgeButton
    └── 其他移动端按钮
```

`MoveJoystick` 不建议覆盖整个屏幕。它自身是一个 `Control`，其矩形范围也就是它接收触摸的区域。通常应设为**屏幕左下约 40%~50% 宽度、45%~55% 高度**的区域，避免与右侧攻击、闪避、交互按钮冲突。

推荐初始参数：

|属性|推荐值|含义|
|---|--:|---|
|`action_left`|`move_left`|左方向动作|
|`action_right`|`move_right`|右方向动作|
|`action_up`|`move_up`|上方向动作|
|`action_down`|`move_down`|下方向动作|
|`joystick_size`|140~200|摇杆底座直径，单位 px|
|`tip_size`|`joystick_size * 0.5`|摇杆头直径|
|`clampzone_ratio`|`1.0`|摇杆头最大移动半径|
|`deadzone_ratio`|`0.0`|推荐交给 InputMap 管理死区|
|`visibility_mode`|`WHEN_TOUCHED` 或 `ALWAYS`|触摸时显示或常显|
|`initial_offset_ratio`|`Vector2(0.5, 0.7)`|摇杆初始位置，相对于节点自身区域|

`joystick_size` 是视觉底座的直径；实际摇杆头在 `clampzone_ratio = 1.0` 时最多移动 `joystick_size / 2`。例如旧项目的 `max_len = 70`，可从 `joystick_size = 140` 开始；旧 `max_len = 120`，可先试 `joystick_size = 240`。`clampzone_ratio` 会按摇杆半径缩放最大位移范围。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))

---

## 3. 三种摇杆模式的选择

|模式|使用场景|行为|
|---|---|---|
|`JOYSTICK_FIXED`|固定左下摇杆|底座永远不动|
|`JOYSTICK_DYNAMIC`|常见移动端动态摇杆|按下位置成为临时中心，松手后回到初始位置|
|`JOYSTICK_FOLLOWING`|需要允许手指大范围拖动|超出摇杆范围后，底座会跟随手指移动，松手后复位|

你旧项目中有“左半屏触摸拖动”的设计，默认优先使用：

```text
joystick_mode = JOYSTICK_FOLLOWING
visibility_mode = VISIBILITY_WHEN_TOUCHED
```

若希望摇杆固定在左下角，改用：

```text
joystick_mode = JOYSTICK_FIXED
visibility_mode = VISIBILITY_ALWAYS
```

官方节点定义了 Fixed、Dynamic、Following 三种行为；Dynamic 与 Following 在松手后都会回到初始位置。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))

---

## 4. 玩家移动代码：只读取 InputMap

### 2D 移动

```gdscript
const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const MOVE_UP := &"move_up"
const MOVE_DOWN := &"move_down"

func get_move_input() -> Vector2:
	return Input.get_vector(
		MOVE_LEFT,
		MOVE_RIGHT,
		MOVE_UP,
		MOVE_DOWN
	)

func _physics_process(_delta: float) -> void:
	var move_input := get_move_input()
	velocity = move_input * move_speed
	move_and_slide()
```

### 3D 第三人称移动

```gdscript
const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const MOVE_FORWARD := &"move_up"
const MOVE_BACK := &"move_down"

func get_move_input() -> Vector2:
	return Input.get_vector(
		MOVE_LEFT,
		MOVE_RIGHT,
		MOVE_FORWARD,
		MOVE_BACK
	)

func get_camera_relative_move_direction(camera: Camera3D) -> Vector3:
	var input_vector := get_move_input()
	if input_vector.is_zero_approx():
		return Vector3.ZERO

	var camera_basis := camera.global_transform.basis
	var forward := -camera_basis.z
	var right := camera_basis.x

	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var direction := right * input_vector.x + forward * input_vector.y
	return direction.normalized() * input_vector.length()
```

这里必须保留 `input_vector.length()`：它保留官方虚拟摇杆的推杆力度，使触摸轻推、手柄轻推都能得到较低移动速度。

`Input.get_vector()` 会根据四个动作生成长度不超过 1 的输入向量，并支持圆形死区。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_input.html?utm_source=chatgpt.com "Input — Godot Engine (4.7) documentation in English"))

---

## 5. 死区规则：只能有一个主要来源

官方 `VirtualJoystick` 有 `deadzone_ratio`，而 InputMap 的每个动作也有 deadzone。两者同时启用时，虚拟摇杆死区会先执行，随后 InputMap 死区再执行。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))

### 推荐方案：统一由 InputMap 管理

```text
VirtualJoystick.deadzone_ratio = 0.0
InputMap move_* deadzone = 0.12 ~ 0.18
```

优点：

- 触屏、手柄、键盘经过同一套规则。
    
- 手柄摇杆轻微漂移也能被过滤。
    
- 不会出现“虚拟摇杆死区 + InputMap 死区”叠加造成的迟钝感。
    

不要在旧玩家脚本中继续保留：

```gdscript
if joystick_vector.length() < deadzone:
	joystick_vector = Vector2.ZERO
```

不要保留：

```gdscript
@export var touch_deadzone := 0.2
@export var joystick_deadzone := 0.15
```

这些旧死区逻辑应完全删除。

---

## 6. 不要把 `VirtualJoystick` 当成“自定义向量提供者”

Godot 4.7 的公开 API 核心是：

1. 配置四个方向 Action。
    
2. 由节点模拟这些 Action。
    
3. 角色从全局 `Input` 读取动作状态。
    
4. 通过 `pressed`、`released(input_vector)`、`tapped`、`flicked(input_vector)` 等信号处理可选反馈。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))
    

因此：

### 禁止保留

```gdscript
@onready var joystick = $VirtualJoystick

func _physics_process(_delta):
	var input_direction = joystick.output
```

```gdscript
func get_joystick_direction() -> Vector2:
	return current_touch_position - touch_origin
```

```gdscript
Input.action_press("move_left", custom_strength)
```

```gdscript
func _input(event):
	if event is InputEventScreenDrag:
		_update_virtual_stick(event.position)
```

### 正确做法

```gdscript
var input_direction := Input.get_vector(
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down"
)
```

不要自己调用 `Input.action_press()` 模拟移动；官方节点已经负责方向动作和模拟量强度。Godot 4.7 的实现会根据摇杆位置更新方向 Action 的按下与释放状态。([GitHub](https://raw.githubusercontent.com/godotengine/godot/master/scene/gui/virtual_joystick.cpp "raw.githubusercontent.com"))

---

## 7. 旧系统必须删除的范围

以下内容必须在每个项目中全量检索、迁移、删除。

### 场景与节点

删除所有旧节点、旧场景和旧预制体，例如：

```text
VirtualJoystick.tscn
TouchJoystick.tscn
Joystick.tscn
MobileJoystick.tscn
TouchMovementController.tscn
MobileInputOverlay.tscn
```

也删除旧节点树中的：

```text
JoystickBase
JoystickKnob
StickArea
TouchArea
DragArea
LeftStick
Thumbstick
MovePad
```

### 脚本与类

删除所有旧摇杆实现、包装器、桥接器和兼容层，例如：

```text
virtual_joystick.gd
touch_joystick.gd
mobile_joystick.gd
joystick_controller.gd
touch_input_manager.gd
mobile_input_manager.gd
```

```gdscript
class_name VirtualJoystick
class_name TouchJoystick
class_name MobileJoystick
class_name JoystickController
```

也删除旧变量：

```gdscript
drag_start
finger_id
touch_id
touch_origin
stick_origin
knob_position
max_len
max_distance
joystick_vector
raw_joystick_vector
is_dragging
is_touching
touch_deadzone
```

### 资源与插件

删除所有只服务于旧摇杆的资源：

```text
joystick_base.png
joystick_knob.png
thumbstick_bg.png
thumbstick_handle.png
mobile_stick_theme.tres
```

不要把旧摇杆贴图“换个文件名后继续给官方节点用”。这次迁移的目标是彻底弃用旧实现及其关联内容。

如需要视觉定制，创建新的官方 Theme / StyleBox 资源，例如：

```text
res://ui/themes/virtual_joystick_theme.tres
```

官方节点支持 `normal_joystick`、`normal_tip`、`pressed_joystick`、`pressed_tip` 四个 StyleBox Theme 项。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))

### 不应删除的触摸功能

以下功能不是旧虚拟摇杆本体，应保留：

- 点击 UI 按钮。
    
- 点击场景物体。
    
- 长按、拖拽背包格子。
    
- 双指缩放、旋转镜头。
    
- 与移动摇杆无关的手势识别。
    
- 独立的攻击、闪避、技能触屏按钮。
    

判断原则：

```text
只要某段触摸逻辑存在的唯一目的，是计算“移动摇杆方向”，就删除。
只要某段触摸逻辑服务于其他交互，就保留。
```

---

## 8. 多项目迁移执行顺序

每个项目独立执行，不创建跨项目共享的旧兼容插件。

### 第一步：代码审计

先检索：

```bash
rg -n -i "joystick|thumbstick|touch.*move|mobile.*input|stick_vector|max_len|touch_origin|finger_id" res://
```

再检索：

```bash
rg -n "InputEventScreenTouch|InputEventScreenDrag|action_press|action_release" res://
```

将结果分为四类：

|分类|处理方式|
|---|---|
|旧虚拟摇杆场景 / 脚本|删除|
|角色中读取旧摇杆向量的代码|改为 `Input.get_vector()`|
|旧移动专用 InputMap 动作|迁移后删除|
|非移动用途的触摸逻辑|保留，但不得继续向移动系统传递摇杆向量|

### 第二步：先建立官方输入链路

1. 项目升级到 Godot 4.7。
    
2. 创建统一 `move_left/right/up/down`。
    
3. 键盘、手柄重新绑定到这四个动作。
    
4. 添加一个官方 `VirtualJoystick`。
    
5. 配置四个 Action。
    
6. 将玩家移动改为 `Input.get_vector()`。
    
7. 在确认移动正常前，不删除旧文件以外的非摇杆功能。
    

### 第三步：一次性删除旧系统

确认官方摇杆在真机正常后：

1. 删除旧摇杆节点与脚本。
    
2. 删除旧 Autoload。
    
3. 删除旧输入 Action。
    
4. 删除旧主题、纹理、场景资源。
    
5. 删除旧测试场景与旧测试代码。
    
6. 删除所有兼容方法，例如 `get_joystick_vector()`。
    
7. 删除“触屏 / 非触屏”两套移动分支。
    

最终代码中不应存在：

```text
旧摇杆节点
旧摇杆脚本
旧摇杆资源
旧摇杆动作
旧摇杆变量
旧摇杆兼容接口
旧摇杆输入分支
```

---

## 9. 验收标准

### 静态验收

```text
[ ] 项目内没有旧 VirtualJoystick / TouchJoystick / MobileJoystick 自定义类。
[ ] 项目内没有旧摇杆场景和旧摇杆贴图。
[ ] Project Settings 的 Input Map 中没有 touch_* / joystick_* 等遗留动作。
[ ] 玩家移动脚本不读取任何旧摇杆节点。
[ ] 玩家移动脚本不处理移动专用的 InputEventScreenDrag。
[ ] 没有 get_joystick_vector()、get_touch_direction() 等兼容接口。
[ ] 没有手动 Input.action_press() 来模拟移动。
```

### 功能验收

```text
[ ] 键盘移动正常。
[ ] 手柄左摇杆移动正常。
[ ] 触屏摇杆移动正常。
[ ] 轻推摇杆时，角色保留低输入强度。
[ ] 斜向移动速度不会超过直向移动速度。
[ ] 松开触屏后，角色立即停止。
[ ] 持续按住左侧摇杆时，右侧攻击 / 闪避按钮仍可同时使用。
[ ] 横竖屏或不同分辨率下，摇杆仍在正确的左下区域。
[ ] iOS 真机上无卡住移动、无残留输入、无触摸冲突。
[ ] 删除旧摇杆资源后，项目无 Missing Node、Missing Script、Missing Resource。
```

---

# 可直接交给 Codex 的迁移提示词

```text
任务：将当前 Godot 项目的旧虚拟摇杆系统彻底替换为 Godot 4.7 官方 VirtualJoystick。

工作方式：
1. 第一轮只读，不修改任何文件。
2. 先输出完整审计结果、迁移计划、涉及文件、代码替换方案和测试方案。
3. 不创建兼容层，不保留旧接口，不保留旧节点，不保留旧资源，不保留旧 InputMap 动作。
4. 不要创建新的自定义摇杆脚本、VirtualJoystick 包装器、TouchInputManager 或输入桥接层。
5. 角色移动必须统一改为从 Input.get_vector(
   "move_left",
   "move_right",
   "move_up",
   "move_down"
   ) 读取输入。
6. 触摸、键盘、手柄必须共用同一套移动逻辑。
7. 旧虚拟摇杆相关脚本、场景、Autoload、贴图、Theme、输入动作、变量、测试和文档都必须标记为删除对象。
8. 保留与移动摇杆无关的点击、长按、背包拖拽、攻击按钮、闪避按钮和其他独立触摸交互。
9. 默认使用 Godot 4.7 官方 VirtualJoystick，不使用第三方摇杆插件。

目标 InputMap：
- move_left
- move_right
- move_up
- move_down

官方 VirtualJoystick 配置：
- action_left = move_left
- action_right = move_right
- action_up = move_up
- action_down = move_down
- joystick_mode = JOYSTICK_FOLLOWING
- visibility_mode = VISIBILITY_WHEN_TOUCHED
- deadzone_ratio = 0.0
- InputMap 的 move_* 动作负责统一 deadzone
- joystick_size 与 tip_size 根据旧 max_len 和实际 UI 尺寸重新映射，不直接复制旧实现

请按以下结构输出：

# 1. 旧系统审计
- 所有旧摇杆脚本
- 所有旧摇杆场景
- 所有旧摇杆资源
- 所有旧摇杆 Autoload
- 所有旧摇杆输入动作
- 所有旧摇杆变量、方法、信号和调用点
- 区分“必须删除”和“应保留的非移动触摸逻辑”

# 2. 最终架构
- VirtualJoystick 放置位置
- UI 节点结构
- InputMap 配置
- 玩家移动输入入口
- 是否需要针对 2D / 3D 做不同的相机相对移动转换

# 3. 逐文件修改计划
每个文件说明：
- 文件路径
- 当前旧职责
- 删除 / 修改 / 保留
- 具体替换内容
- 依赖影响

# 4. 代码
- 输出完整、可直接手动替换的 GDScript 代码块
- 不输出伪代码
- 不创建兼容接口
- 不保留旧摇杆变量

# 5. 清理清单
- 应删除的文件
- 应删除的节点
- 应删除的资源
- 应删除的 InputMap 动作
- 应删除的 Autoload
- 应删除的文档和测试

# 6. 测试方案
- 编辑器验证
- 键盘验证
- 手柄验证
- 触屏验证
- 双指：左摇杆 + 右侧技能按钮验证
- 不同分辨率验证
- iOS 真机验证
- 静态检索命令，确保旧摇杆实现没有残留
```

官方节点的三个模式、方向 Action 映射、死区规则、Theme 定制项与触摸信号均以 Godot 4.7 文档为准。([Godot Engine documentation](https://docs.godotengine.org/en/4.7/classes/class_virtualjoystick.html "VirtualJoystick — Godot Engine (4.7) documentation in English"))