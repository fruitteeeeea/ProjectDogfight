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

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

var target_point : int
var warning_started := false
var duration := 60.0

func mission_start(_time: float, point: int) -> void:
	bgm_player.play()
	duration = _time
	warning_started = false
	mission_timer.start(_time)
	target_points_label.text = "/ " + str(point) + " pts. "
	target_point = point
	display_mission_panel()


func _physics_process(delta: float) -> void:
	update_mission_info()
	if GameStatusServer.is_battle_active() and not warning_started and mission_timer.time_left <= duration * (1.0 - alert_threshold):
		warning_started = true
		blink_canvs_item.start_tween()


func update_mission_info() -> void:
	time_left_label.text = seconds_to_mmss(mission_timer.time_left)
	current_points_label.text = str(GameStatusServer.your_points)


func seconds_to_mmss(t: float) -> String:
	var total_sec := int(t)
	var minutes := total_sec / 60
	var seconds := total_sec % 60
	return "%02d : %02d" % [minutes, seconds]


#region Tween
func display_mission_panel() -> void:
	show()
	position.y = -128.0
	modulate.a = 0.0
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(self, "position:y", 0.0, .5)
	tween.tween_property(self, "modulate:a", 1.0, .5)

#endregion
