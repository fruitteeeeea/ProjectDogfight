extends JetBase
class_name Player

var base_accel : float = 1.0

var burst_accel : float = 1.0
var burst_ratio : float = 1.0

var force_dir : Vector2 = Vector2.ZERO

var engine_on : bool = true

#引擎关闭
@export var engine_off_burst_accel := - 0.4 
@export var engine_off_burst_ratio := 1.0

@export var engine_off_turn_speed := 1.5 #引擎关闭的时候转向倍率 

@export var gravity_dir := Vector2.DOWN
@export var fall_strength := 0.4  # 下坠影响程度（0~1）

@onready var engine_on_label: CanvasGroup = $AccelerateComponent/CanvasLayer/AccelHUD/EngineOnLabel
@onready var engine_on_particle: CPUParticles2D = $Graphic/EngineOnParticle
@onready var engine_off_label: Label = $AccelerateComponent/CanvasLayer/AccelHUD/EngineOffLabel

#开启加速
@export var accelerate_burst_accel :=  1.8
@export var accelerate_off_burst_ratio := 2.0

@export var accelerate_turn_speed := 1.5 #引擎关闭的时候转向倍率 


@onready var limbo_hsm: LimboHSM = $LimboHSM
@onready var engine_on_state: LimboState = $LimboHSM/EngineOnState
@onready var engine_off_state: LimboState = $LimboHSM/EngineOffState
@onready var burst_accelerate_state: LimboState = $LimboHSM/BurstAccelerateState

@onready var misson: MissionPanel = $HUD/Misson

@onready var trail: CPUParticles2D = $Graphic/Trail
@onready var flame: CPUParticles2D = $Graphic/Flame

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud_offset_manager: HUDOffsetManager = $HUD/HUDOffsetManager

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("engine"): #切换引擎状态 
		engine_on = !engine_on
		
	if event.is_action_pressed("dodge"):
		hud_offset_manager.trigger_dodge_shake()
		animation_player.play("dodge")

func _ready() -> void:
	_init_state_machine()


func _init_state_machine(): #初始化状态机
	limbo_hsm.add_transition(limbo_hsm.ANYSTATE, engine_on_state, "EngineOn")
	limbo_hsm.add_transition(engine_on_state, engine_off_state, engine_on_state.EVENT_FINISHED)
	limbo_hsm.add_transition(engine_off_state, engine_on_state, engine_off_state.EVENT_FINISHED)
	
	limbo_hsm.initialize(self)
	limbo_hsm.set_active(true)


func _get_move_direction(delta) -> Vector2:
	var forward_dir : Vector2 =  _get_forward(delta)
	if engine_on:
		return forward_dir
	else:
		move_direction = move_direction.lerp(
			gravity_dir,
			fall_strength * delta
		).normalized()
		return move_direction


func _get_forward(delta) -> Vector2:
	if !force_dir:
		target_forward = (get_global_mouse_position() - global_position).normalized()
	
	check_position()
	super(delta)
	return forward


func _get_speed() -> float:
	return _get_final_speed()


func _get_final_speed() -> float:
	var _speed = speed
	return _speed * _get_burst_accel()

#持续加速
func _get_burst_accel() -> float:
	base_accel = lerpf(base_accel, burst_accel, .5 * burst_ratio)
	return base_accel


#检查位置 超出边界了 就会强制返回 
func check_position() -> void:
	if WORLD_RECT.has_point(global_position):
		return  # 在范围内，什么都不做

	# 出界了，再判断从哪边出去
	if global_position.y > WORLD_RECT.end.y:
		force_dir = Vector2.UP
	elif global_position.y < WORLD_RECT.position.y:
		force_dir = Vector2.DOWN
	elif global_position.x > WORLD_RECT.end.x:
		force_dir = Vector2.LEFT
	elif global_position.x < WORLD_RECT.position.x:
		force_dir = Vector2.RIGHT
	
	limbo_hsm.dispatch("EngineOn")
