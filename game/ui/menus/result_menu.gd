extends Control
class_name ResultMenu

@export var controller : Control

@onready var battle_complete: VBoxContainer = $BattleComplete
@onready var game_over: VBoxContainer = $GameOver

@onready var your_points: Label = $BattleComplete/VBoxContainer/YourPoints
@onready var enemies_destroyed: Label = $BattleComplete/VBoxContainer/EnemiesDestroyed
@onready var rank: Label = $BattleComplete/VBoxContainer/Rank

@onready var result: Label = $GameOver/HBoxContainer/Result
@onready var blur_background: ColorRect = $BlurBackground

@onready var win: AudioStreamPlayer = $Win
@onready var lose: AudioStreamPlayer = $Lose

@onready var touch_to_retry: Control = $TouchToRetry
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var game_finished = false
var retry_enabled := false
var _retry: Callable
var _animation_tick_usec := 0

func show_battle_result(snapshot: Dictionary, retry: Callable) -> void:
	if game_finished:
		return
	game_finished = true
	your_points.text = "Your points: " + str(snapshot.points)
	enemies_destroyed.text = "Enemies destroyed: " + str(snapshot.kills)
	rank.text = "Rank: " + snapshot.rank
	if snapshot.complete:
		battle_complete.show()
		_display_box(battle_complete)
		win.play()
	else:
		result.text = "Jet has been destroyed" if snapshot.reason == 1 else "Run out of time."
		game_over.show()
		_display_box(game_over)
		lose.play()
	blur_background.show()
	_retry = retry
	$TouchToRetry/TouchScreenButton.hide()
	animation_player.animation_finished.connect(_enable_retry, CONNECT_ONE_SHOT)
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	animation_player.speed_scale = 1.0
	_animation_tick_usec = Time.get_ticks_usec()
	animation_player.play("01")

func _process(_delta: float) -> void:
	if not game_finished:
		return
	var tick := Time.get_ticks_usec()
	animation_player.advance(float(tick - _animation_tick_usec) / 1000000.0)
	_animation_tick_usec = tick

func _enable_retry(_animation: StringName) -> void:
	retry_enabled = true
	touch_to_retry.show()

func _input(event: InputEvent) -> void:
	if not retry_enabled:
		return
	if event is InputEventKey and event.echo:
		return
	var pointer_pressed: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	if pointer_pressed or event.is_action_pressed("start_game"):
		retry_enabled = false
		get_viewport().set_input_as_handled()
		_retry.call()


#region Tween
func _display_text(label : Label) -> void:
	label.visible_ratio = 0.0
	
	var tween = create_tween().set_ignore_time_scale(true).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "visible_ratio", 1.0, 1.0)


func _display_box(box : VBoxContainer) -> void:
	box.position.x = -1080
	box.modulate.a = 0.0
	blur_background.material.set_shader_parameter("blur_amount", 0.0)
	
	var tween = create_tween().set_ignore_time_scale(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(box, "position:x", 0.0, .3)
	tween.tween_property(box, "modulate:a", 1.0, .3)
	tween.tween_property(blur_background.material, "shader_parameter/blur_amount", 4.0, 1.0)
#endregion
