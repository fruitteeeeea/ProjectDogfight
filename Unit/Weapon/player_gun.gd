extends Gun
class_name PlayerGun

@export var trriger_button := "open_fire"

@export var fire_interval : float = .1
@onready var fire_interval_timer: Timer = $fire_interval_timer

@export var max_bullet := 200
@export var current_bullet := 0
@export var reload_speed_curve : Curve

@export var bullet_number: Label
@export var alert_clor : Color = Color.BLACK
@export var alert_threshold : float = .15
@export var fire_on_label: CanvasGroup 
@export var reloding_label: CanvasGroup


var fire_on : bool = false:
	set(v):
		fire_on = v
		if fire_on:
			fire_on_label.show()
			fire_interval_timer.start(fire_interval)
			
			reload_active = false
		else :
			fire_on_label.hide()
			fire_interval_timer.stop()
			
			reload_active = true
			reload_time = 0.0
			reload_accumulator = 0.0

var reload_active := false:
	set(v):
		if reload_active == v:
			return

		reload_active = v
		
		if reload_active:
			reloding_label.show()
		else :
			reloding_label.hide()

var reload_time = 0.0
var reload_accumulator := 0.0

func _ready() -> void:
	current_bullet = max_bullet #初始时补充弹药
	fire_interval_timer.wait_time = fire_interval #赋值开火间隔


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(trriger_button):
		fire_on = !fire_on


func fire() -> void:
	if current_bullet <= 0:
		fire_on = false
		return
	
	current_bullet -= 2
	
	var bullet_offset : Array[Vector2] = [Vector2(0, -12.0), Vector2(0, 12.0)]
	
	for i in range(bullet_offset.size()):
		var pos_offset = bullet_offset.pop_back()
		var dir =  global_transform.x.normalized()

		_fire(pos_offset, dir)


func _on_fire_interval_timer_timeout() -> void:
	fire() 


func _physics_process(delta: float) -> void:
	_update_gun_text()
	_handle_bullet_reload(delta)


func _update_gun_text() -> void:
	bullet_number.text = "Gun : " + str(clamp(current_bullet, 0, max_bullet) ) + "/" + str(max_bullet)

	if current_bullet <= max_bullet * alert_threshold: #更新标签的颜色 
		bullet_number.modulate = alert_clor
	else :
		bullet_number.modulate = Color.WHITE


func _handle_bullet_reload(delta : float) -> void:
	if !reload_active or current_bullet >= max_bullet:
		return

	reload_time += delta
	var progress = clamp(reload_time, 0.0, reload_speed_curve.max_domain)
	var reload_speed := reload_speed_curve.sample(progress)
	
	reload_accumulator += reload_speed * delta
	
	while reload_accumulator >= 1.0:
		current_bullet += 1
		reload_accumulator -= 1.0

		if current_bullet >= max_bullet:
			reload_active = false
			break
