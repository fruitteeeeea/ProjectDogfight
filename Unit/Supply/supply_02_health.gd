extends SupplyPacke
class_name SupplyHealth


func _player_claim_supply() -> void:
	player.take_damage(-10.0)
