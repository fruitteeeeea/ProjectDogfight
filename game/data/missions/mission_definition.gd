class_name MissionDefinition
extends Resource

@export_range(1, 9) var mission_id: int = 1
@export var display_name: String = ""
@export_multiline var objective: String = ""
@export_multiline var background_story: String = ""
@export var available: bool = false
