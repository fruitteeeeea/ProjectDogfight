extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStatusServer.distribute_rewards.connect(_get_your_reward)


func _get_your_reward() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	
	SpwanServer.spwan_player_reward()
	
	animation_player.play("01")
