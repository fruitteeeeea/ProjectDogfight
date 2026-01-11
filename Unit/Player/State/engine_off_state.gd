extends PlayerJetState

var defult_trun_speed : float

var engine_off_turn_speed : float

func _setup() -> void:
	player = agent as Player
	defult_trun_speed = player.turn_speed
	engine_off_turn_speed = player.turn_speed * player.engine_off_turn_speed
	print("EngineOff执行一次")


func _enter() -> void:
	player.turn_speed = engine_off_turn_speed
	player.trail.emitting = false
	player.flame.emitting = false
	print("玩家进入 EngineOff 状态 ")


func _update(delta: float) -> void:
	if player.engine_on: #注意 返回战斗区域不会关闭引擎 
		get_root().dispatch(EVENT_FINISHED)

	


func _exit() -> void:
	player.turn_speed = defult_trun_speed
