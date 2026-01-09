extends PlayerJetState


func _setup() -> void:
	player = agent as Player
	print("Accel 执行一次")


func _enter() -> void:
	print("玩家进入 Accel 状态 ")
