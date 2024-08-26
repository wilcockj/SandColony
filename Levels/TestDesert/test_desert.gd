extends Node3D

@onready var colony_member = $ColonyMember  # Assume you have a ColonyMember in the scene

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
