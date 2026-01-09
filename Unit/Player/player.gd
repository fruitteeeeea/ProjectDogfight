extends JetBase
class_name Player

const WORLD_RECT := Rect2(
	Vector2(-3840.0, -2144.0),  # 左上角
	Vector2(7680.0, 4288.0)    # 宽高
)

var base_accel : float = 1.0
var target_accel : float = 1.0
var burst_accel : float = 1.0:
	set(v):
		burst_accel = v
		print("加速度改变 %s", base_accel)


var force_dir : Vector2 = Vector2.ZERO

var engine_on : bool = true


@onready var limbo_hsm: LimboHSM = $LimboHSM
@onready var engine_on_state: LimboState = $LimboHSM/EngineOnState
@onready var engine_off_state: LimboState = $LimboHSM/EngineOffState
@onready var burst_accelerate_state: LimboState = $LimboHSM/BurstAccelerateState


@onready var trail: CPUParticles2D = $Graphic/Trail
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("engine"): #切换引擎状态 
		engine_on = !engine_on
		
	if event.is_action_pressed("dodge"):
		animation_player.play("dodge")

func _ready() -> void:
	_init_state_machine()


func _init_state_machine(): #初始化状态机
	limbo_hsm.add_transition(limbo_hsm.ANYSTATE, engine_on_state, "EngineOn")
	limbo_hsm.add_transition(engine_on_state, engine_off_state, engine_on_state.EVENT_FINISHED)
	limbo_hsm.add_transition(engine_off_state, engine_on_state, engine_off_state.EVENT_FINISHED)
	
	limbo_hsm.initialize(self)
	limbo_hsm.set_active(true)


func _get_forward(delta) -> Vector2:
	check_position()
	super(delta)
	return forward


func _get_speed() -> float:
	return _get_final_speed()


func _get_final_speed() -> float:
	var _speed = speed
	return _speed * _get_accel() * _get_burst_accel()


func _get_accel() -> float:
	base_accel = lerpf(base_accel, target_accel, .1)
	return base_accel

#持续加速
func _get_burst_accel() -> float:
	#burst_accel = lerpf(burst_accel, 1.0, .1)
	return burst_accel


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
