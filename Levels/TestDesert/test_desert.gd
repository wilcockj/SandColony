extends Node3D

@export var num_bushes: int = 50  # Number of bushes to generate
@export var map_size: Vector2 = Vector2(100, 100)  # Size of your map
@export var ray_height: float = 50.0  # Height from which to cast rays
@export var bush_y_offset: float = 0.5  # Offset to place bush slightly above ground
@export var bush_radius: float = 2.0  # Radius of the navigation obstacle for each bush
@export var level: NavigationRegion3D
@onready var bush_scene = preload("res://Entities/Bush/Bush.tscn")

func _ready():
	generate_bushes()
	level.rebake()

func generate_bushes():
	var space_state = get_world_3d().direct_space_state
	
	for i in range(num_bushes):
		var random_x = randf_range(-map_size.x / 2, map_size.x / 2)
		var random_z = randf_range(-map_size.y / 2, map_size.y / 2)
		
		var ray_origin = Vector3(random_x, ray_height, random_z)
		var ray_end = Vector3(random_x, -ray_height, random_z)
		
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			var bush_instance = bush_scene.instantiate()
			level.add_child(bush_instance)
			var bush_position = result.position + Vector3(0, bush_y_offset, 0)
			bush_instance.global_position = bush_position
			
			print("Bush placed at: ", bush_instance.global_position)
		else:
			print("No surface found for bush at x:", random_x, " z:", random_z)

func assign_harvest_job(member: ColonyMember, bush_position: Vector3, bush: Bush) -> void:
	member.assign_harvest_job(bush_position,bush)
			
