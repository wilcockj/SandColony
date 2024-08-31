class_name Bush extends StaticBody3D
@export var stick_count: int = 5  # Number of sticks available in the bush
var cur_stick_count = stick_count
@export var text_label: Sprite3D

func _ready():
	text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")

func harvest_stick() -> bool:
	if cur_stick_count > 0:
		cur_stick_count -= 1
		text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")
		return true
	else:
		text_label.Set_3D_Text("Bush no sticks")
		return false
