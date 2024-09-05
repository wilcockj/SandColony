extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func sort_ascending_item_count(a, b):
	if b.inventory.get_total_all_items() < a.inventory.get_total_all_items():
		return true
	return false


func set_leaderboard(colony_member_array):
	# search through all of the colony members and 
	# have top 10 harvesters
	colony_member_array.sort_custom(
		sort_ascending_item_count
	)

	# Get the top 10 harvesters
	var top_ten_members = colony_member_array.slice(0, 10)

	# Debu"g print the top 10 members
	var str = ""
	for member in top_ten_members:
		str += "Member: " + str(member.member_id) + " Total Items: " + str(member.inventory.get_total_all_items()) + "\n"

	%LeaderBoard.text = str
