@tool
extends BTAction


@export var target_var: StringName = &"target"
@export var distance: float = 30.0

func _enter() -> void:
	var target := blackboard.get_var(target_var) as Node2D
	var a = agent as Enemy
	
	if is_instance_valid(target):
		if agent.global_position.y - target.global_position.y < 0:
			a.target_forward = Vector2.DOWN
		else :
			a.target_forward = Vector2.UP



func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	var a = agent as Enemy
	
	if not is_instance_valid(target):
		return FAILURE
	
	if agent.global_position.x - target.global_position.x < distance:
		return SUCCESS

	return RUNNING
