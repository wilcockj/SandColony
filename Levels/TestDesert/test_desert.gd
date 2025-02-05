extends Node3D

@export var num_bushes: int = 200  # Number of bushes to generate
@export var num_rocks: int = 200

@export var map_size: Vector2 = Vector2(200, 200)  # Size of your map
@export var ray_height: float = 50.0  # Height from which to cast rays
@export var bush_y_offset: float = 0.5  # Offset to place bush slightly above ground
@export var bush_radius: float = 2.0  # Radius of the navigation obstacle for each bush
@export var level: NavigationRegion3D
@export var ui: Control
@onready var bush_scene = preload("res://Entities/Bush/Bush.tscn")
@onready var rock_scene = preload("res://Entities/Rock/Rock.tscn")
@onready var colony_member = preload("res://Entities/Colony_Member/Colony_Member.tscn")

var colony_member_list = []

func _ready():
	generate_bushes()
	generate_rocks()
	level.rebake()
	place_colony_members()

func place_colony_members():
	colony_member_list = place_node_randomly(colony_member, 1.0, 100)
	for i in colony_member_list.size():
		colony_member_list[i].member_id = i

func generate_bushes():
	place_node_randomly(bush_scene, bush_y_offset, num_bushes)

func generate_rocks():
	place_node_randomly(rock_scene, bush_y_offset, num_rocks)



func place_node_randomly(node, offset, num):
	var space_state = get_world_3d().direct_space_state
	
	var num_placed = 0
	var placed_node_list = []
	while num_placed < num:
		var random_x = randf_range(-map_size.x / 2, map_size.x / 2)
		var random_z = randf_range(-map_size.y / 2, map_size.y / 2)
		
		var ray_origin = Vector3(random_x, ray_height, random_z)
		var ray_end = Vector3(random_x, -ray_height, random_z)
		
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			var instance = node.instantiate()
			level.add_child(instance)
			var node_position = result.position + Vector3(0, offset, 0)
			instance.global_position = node_position
			
			print("Node placed at: ", instance.global_position)
			num_placed += 1
			placed_node_list.append(instance)
		else:
			print("No surface found for node at x:", random_x, " z:", random_z)
	return placed_node_list

func assign_harvest_job(member: ColonyMember, bush_position: Vector3, bush: Bush) -> void:
	member.assign_harvest_job(bush_position,bush)
			


func _on_update_leader_board_timer_timeout() -> void:
	%UI.set_leaderboard(colony_member_list)
