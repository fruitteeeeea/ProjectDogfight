class_name MissionCatalog
extends Resource

@export var missions: Array[MissionDefinition] = []

func find_mission(id: int) -> MissionDefinition:
	for mission in missions:
		if mission != null and mission.mission_id == id:
			return mission
	return null
