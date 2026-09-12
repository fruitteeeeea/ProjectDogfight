extends PanelContainer

@onready var name_label: Label = %MissionName
@onready var objective_label: Label = %Objective
@onready var story_label: Label = %BackgroundStory

func display_mission(mission: MissionDefinition) -> void:
	name_label.text = mission.display_name if mission != null else "Mission unavailable"
	objective_label.text = mission.objective if mission != null else ""
	story_label.text = mission.background_story if mission != null else ""
