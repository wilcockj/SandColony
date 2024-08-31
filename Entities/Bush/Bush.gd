class_name Bush extends StaticBody3D
@export var stick_count: int = 5  # Number of sticks available in the bush

func harvest_stick() -> bool:
	if stick_count > 0:
		stick_count -= 1
		return true
	else:
		return false
