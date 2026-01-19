extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStatusServer.distribute_rewards.connect(_get_your_reward)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		GameStatusServer.enemy_destory += 1


func _get_your_reward() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	
	animation_player.play("01")
	pass
