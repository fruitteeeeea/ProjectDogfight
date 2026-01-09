extends PlayerJetState


func _setup() -> void:
	player = agent as Player
	print("EngineOff执行一次")


func _enter() -> void:
	player.turn_speed = 1.0
	player.trail.emitting = false
	print("玩家进入 EngineOff 状态 ")


func _update(delta: float) -> void:
	
	if player.velocity.x > 0:
		player.target_forward = Vector2(1, 1)
	else :
		player.target_forward = Vector2(-1, 1)
	
	
	if player.engine_on: #注意 返回战斗区域不会关闭引擎 
		get_root().dispatch(EVENT_FINISHED)
