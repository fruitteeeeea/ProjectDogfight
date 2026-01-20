extends WayPointIcon
class_name EnemyIndicator

var enemy : Enemy

func _ready() -> void:
	if target is Enemy:
		enemy = target

func _physics_process(delta: float) -> void:
	if enemy.is_dead:
		queue_free()
	
	super(delta)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	hide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	show()
