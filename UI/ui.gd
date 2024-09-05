extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_leaderboard(colony_member_array):
	# search through all of the colony members and 
	# have top 10 harvesters
	print(colony_member_array)
	var top_ten_members = []
	#for member in colony_member_array:
		
