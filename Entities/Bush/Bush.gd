class_name Bush extends StaticBody3D
@export var stick_count: int = 5  # Number of sticks available in the bush
var cur_stick_count = stick_count
@export var text_label: Sprite3D

func _ready():
	text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")

func harvest_stick() -> bool:
	if cur_stick_count > 0:
		cur_stick_count -= 1
		if cur_stick_count == 0:
			text_label.Set_3D_Text("Bush no sticks")
		else:
			text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")
		return true
	else:
		return false

func has_work() -> bool:
	return cur_stick_count > 0
