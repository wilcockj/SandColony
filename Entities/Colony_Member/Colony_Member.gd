class_name ColonyMember extends CharacterBody3D

@export var speed: float = 5.0  # Movement speed
var target_position: Vector3 = Vector3.ZERO  # Position to move towards
var current_job: String = ""
var current_bush: Bush
var at_target: bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const HARVEST_COOLDOWN = 1.0
var harvest_cooldown = HARVEST_COOLDOWN

func _physics_process(delta: float) -> void:
	if current_job == "harvest" and target_position != Vector3.ZERO:
		move_toward_target(delta)
		
	if not is_on_floor():
		velocity.y -= gravity * delta * speed
		move_and_slide()
		
	harvest_cooldown -= delta
	if harvest_cooldown <= 0: 
		if at_target:
			harvest_cooldown = HARVEST_COOLDOWN
			try_harvest()
	

func move_toward_target(delta: float) -> void:
	if global_transform.origin.distance_to(target_position) < 2:
		_on_reach_target()
		target_position = Vector3.ZERO
		return
	var direction = (target_position - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func try_harvest():
	if current_job != "harvest":
		return
	if current_bush and current_bush.harvest_stick():
		print("Stick harvested!")
		# set timer for some time to try to harvest again
	else:
		print("No more sticks!")
		current_job = ""  # Clear job after harvesting

func _on_reach_target() -> void:
	at_target = true

func assign_harvest_job(target: Vector3, bush: Bush):
	at_target = false
	target_position = target
	current_bush = bush
	current_job = "harvest"
