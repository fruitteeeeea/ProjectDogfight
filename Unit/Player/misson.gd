extends Control
class_name MissionPanel


@onready var mission_timer: Timer = $MissionTimer
@onready var target_points_label: Label = $Time/HBoxContainer/TargetPointsLabel

@onready var time_left_label: Label = $Time/PanelContainer2/PanelContainer/TimeLeftLabel
@onready var current_points_label: Label = $Time/HBoxContainer/CurrentPointsLabel
 
@onready var blink_canvs_item: BlinkCanvasItem = $Time/PanelContainer2/BlinkCanvsItem

@export var alert_threshold := .8 
@export var player : Player
@export var player_damage_component : PlayerDamageComponent

var target_point : int

func _ready() -> void:
	player.player_dead.connect(_mission_fall)


func mission_start(_time : float, point : int) -> void:
	GameStatusServer.reset_game_status()
	mission_timer.start(_time)
	target_points_label.text = "/ " + str(point) + " pts. "
	target_point = point
	display_mission_panel()
	player_damage_component.test_state = false

	await get_tree().create_timer(_time * alert_threshold).timeout
	blink_canvs_item.start_tween() #倒计时警告 


func _mission_fall() -> void:
	GameStatusServer.show_result.emit(false)


func _physics_process(delta: float) -> void:
	update_mission_info()


func update_mission_info() -> void:
	time_left_label.text = seconds_to_mmss(mission_timer.time_left)
	current_points_label.text = str(GameStatusServer.your_points)


func seconds_to_mmss(t: float) -> String:
	var total_sec := int(t)
	var minutes := total_sec / 60
	var seconds := total_sec % 60
	return "%02d : %02d" % [minutes, seconds]


func _on_mission_timer_timeout() -> void:
	#这里对游戏结果进行判断 
	if GameStatusServer.your_points < target_point:
		GameStatusServer.show_result.emit(false) #游戏失败 
	
	else :
		GameStatusServer.show_result.emit(true) #游戏完成！


#region Tween
func display_mission_panel() -> void:
	show()
	position.y = -128.0
	modulate.a = 0.0
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(self, "position:y", 0.0, .5)
	tween.tween_property(self, "modulate:a", 1.0, .5)

#endregion
