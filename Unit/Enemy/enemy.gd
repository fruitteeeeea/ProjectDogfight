extends JetBase
class_name Enemy

@onready var color_rect: ColorRect = $ColorRect
@onready var bt_player: BTPlayer = $BTPlayer

@onready var damage_component: DamageComponent = $DamageComponent

func _ready() -> void:
	target_forward = [Vector2.LEFT, Vector2.RIGHT].pick_random()


#获取带有偏差的目标方向 
func add_random_angle(dir: Vector2, max_deg := 15.0) -> Vector2:
	var angle_offset = randf_range(-max_deg, max_deg)
	return dir.normalized().rotated(deg_to_rad(angle_offset))



func take_damage() -> void:
	if is_dead:
		return
	
	damage_component.take_damage(10.0)


func die() -> void:
	super()
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
	target_forward = add_random_angle(Vector2(crash_dir_x,  1.0), 30)
	await get_tree().create_timer(5.0).timeout
	queue_free()





#region State
func _enter_combat_area() -> void:
	color_rect.color = Color.YELLOW


func _enter_attack_state() -> void:
	color_rect.color = Color.RED


func _enter_flank_state() -> void:
	color_rect.color = Color.GREEN


func _enter_dead_state() -> void:
	color_rect.color = Color.GRAY
#endregion
