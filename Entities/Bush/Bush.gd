class_name Bush extends StaticBody3D
@export var stick_count: int = 20  # Number of sticks available in the bush
var cur_stick_count = stick_count
@export var text_label: Sprite3D
@onready var grow_timer: Timer = %GrowTimer
var being_worked = false
var id_working

func _ready():
	text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")

func harvest_stick() -> bool:
	if cur_stick_count > 0:
		cur_stick_count -= 1
		if cur_stick_count == 0:
			text_label.Set_3D_Text("Bush no sticks")
			$MeshInstance3D.mesh.material.albedo_color = Color.LIGHT_GREEN
		else:
			text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")
		return true
	else:
		#print("starting grow timer")
		grow_timer.start()
		done_working()
		return false

func has_work() -> bool:
	return cur_stick_count > 0 && !being_worked

func done_working():
	being_worked = false
	
func mark_working(id):
	id_working = id
	being_worked = true

func is_claimed_by_other(id):
	if id_working != id:
		return true

func _on_grow_timer_timeout() -> void:
	$MeshInstance3D.mesh.material.albedo_color = Color.RED
	#print("Grew sticks back")
	cur_stick_count = stick_count
	text_label.Set_3D_Text("Bush " + str(cur_stick_count) + "/" + str(stick_count) + " sticks")
