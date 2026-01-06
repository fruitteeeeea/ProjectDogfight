extends Node2D

@onready var enemy_indicator: TextureRect = $EnemyIndicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	enemy_indicator.global_position = mouse_pos
	enemy_indicator.global_position.x = clamp(mouse_pos.x, -256, 256)
	enemy_indicator.global_position.y = clamp(mouse_pos.y, -256, 256)
	
	if mouse_pos.distance_squared_to(Vector2.ZERO) <= 256 * 256:
		enemy_indicator.hide()
	else :
		enemy_indicator.show()
