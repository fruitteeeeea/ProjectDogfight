extends JetBase
class_name Enemy

@onready var color_rect: ColorRect = $ColorRect
@onready var bt_player: BTPlayer = $BTPlayer
@onready var enemy_damage_component: EnemyDamageComponent = $EnemyDamageComponent


#行为树使用的移动速度和转身速度加成 
@export var movement_speed_buffer : float = 1.0
@export var turn_speed_buffer : float = 1.0

func _ready() -> void:
	target_forward = [Vector2.LEFT, Vector2.RIGHT].pick_random()


func _physics_process(delta: float) -> void:
	super(delta)
	_update_debug_label()

#region 移动速度和转身速度
func _get_speed() -> float:
	return speed * movement_speed_buffer


func _get_forward(delta) -> Vector2:
	forward = forward.slerp(target_forward, 1.0 - exp(-turn_speed * turn_speed_buffer * delta))
	return forward

#endregion

#region TakeDamage
func take_damage(damage : float) -> void:
	if is_dead:
		return
	
	enemy_damage_component.take_damage(damage)


func die() -> void:
	super()
	GameStatusServer.your_points += 100
	GameStatusServer.enemy_destory += 1
	bt_player.active = false
	_enter_dead_state()
	_crash()

#坠机！
func _crash() -> void:
	var crash_dir_x : float = 1.0
	if velocity.y >= 0:
		crash_dir_x = -1.0
	
	turn_speed = 50.0
	target_forward = Vector2(crash_dir_x, -1.0)
	await  get_tree().create_timer(randf_range(.25, .5)).timeout
	turn_speed = 2.5
	target_forward = JetMath.add_random_offset_to_angle(Vector2(crash_dir_x,  1.0), 30)
	await get_tree().create_timer(5.0).timeout
	queue_free()
#endregion

#region DebugState
@onready var velocity_info: Label = $WorldLabel2D/VelocityInfo

func _update_debug_label() -> void:
	velocity_info.text = "speed : %.1f\ndir : (%.2f, %.2f)" % [
	speed,
	target_forward.x,
	target_forward.y
]

func _enter_combat_area() -> void:
	color_rect.color = Color.YELLOW


func _enter_attack_state() -> void:
	color_rect.color = Color.RED


func _enter_flank_state() -> void:
	color_rect.color = Color.GREEN


func _enter_dead_state() -> void:
	color_rect.color = Color.GRAY
#endregion
