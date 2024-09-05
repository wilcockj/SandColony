class_name Rock extends StaticBody3D
@export var rock_count: int = 20  # Number of sticks available in the bush
var cur_rock_count = rock_count
@export var text_label: Sprite3D
@onready var grow_timer: Timer = %GrowTimer
var being_worked = false
var id_working
var item_name = "stone"

func _ready():
	text_label.Set_3D_Text("Rock " + str(cur_rock_count) + "/" + str(rock_count) + " rocks")

func harvest() -> bool:
	if cur_rock_count > 0:
		cur_rock_count -= 1
		if cur_rock_count == 0:
			text_label.Set_3D_Text("Rock no rocks")
			#$MeshInstance3D.mesh.material.albedo_color = Color.LIGHT_GREEN
		else:
			text_label.Set_3D_Text("Rock " + str(cur_rock_count) + "/" + str(rock_count) + " rocks")
		return true
	else:
		#print("starting grow timer")
		grow_timer.start()
		done_working()
		return false

func has_work() -> bool:
	return cur_rock_count > 0 && !being_worked

func done_working():
	being_worked = false
	
func mark_working(id):
	id_working = id
	being_worked = true

func is_claimed_by_other(id):
	if id_working != id:
		return true

func _on_grow_timer_timeout() -> void:
	#$MeshInstance3D.mesh.material.albedo_color = Color.RED
	#print("Grew sticks back")
	cur_rock_count = rock_count
	text_label.Set_3D_Text("Rock " + str(cur_rock_count) + "/" + str(rock_count) + " rocks")
