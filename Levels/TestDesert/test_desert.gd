extends Node3D

@onready var colony_member = $ColonyMember  # Assume you have a ColonyMember in the scene
@export var num_bushes: int = 20  # Number of bushes to generate
@export var map_size: Vector2 = Vector2(100, 100)  # Size of your map
@export var ray_height: float = 50.0  # Height from which to cast rays
@export var bush_y_offset: float = 0.5  # Offset to place bush slightly above ground
@export var bush_radius: float = 2.0  # Radius of the navigation obstacle for each bush

@onready var bush_scene = preload("res://Entities/Bush/Bush.tscn")

func _ready():
	generate_bushes()

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
			add_child(bush_instance)
			var bush_position = result.position + Vector3(0, bush_y_offset, 0)
			bush_instance.global_position = bush_position
			
			# Create a navigation obstacle for the bush
			create_navigation_obstacle(bush_position)
			
			print("Bush placed at: ", bush_instance.global_position)
		else:
			print("No surface found for bush at x:", random_x, " z:", random_z)

func create_navigation_obstacle(position: Vector3):
	var obstacle = NavigationObstacle3D.new()
	add_child(obstacle)
	obstacle.global_position = position
	
	# Set the radius of the obstacle
	obstacle.radius = bush_radius
	
	# You might need to estimate the height of the bush and set it here
	obstacle.height = 2.0  # Adjust this value based on your bush model's height



func assign_harvest_job(colony_member: ColonyMember, bush_position: Vector3, bush: Bush) -> void:
	colony_member.assign_harvest_job(bush_position,bush)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var camera = get_viewport().get_camera_3d()
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_direction = camera.project_ray_normal(event.position)
		
		# Adjust the ray length if necessary, e.g., 100 units forward
		var ray_end = ray_origin + ray_direction * 100.0
		
		# Get the world's direct space state
		var space_state = get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.from = ray_origin
		params.to = ray_end
		params.exclude = []
		params.collision_mask = 1
		var result = space_state.intersect_ray(params)

		if result and result.collider is Bush:
			print("got a bush")
			assign_harvest_job(colony_member, result.collider.global_transform.origin, result.collider)
