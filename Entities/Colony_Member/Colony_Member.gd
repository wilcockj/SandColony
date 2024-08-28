class_name ColonyMember extends CharacterBody3D
@export var speed: float = 10.0  # Movement speed
@export var nav_agent: NavigationAgent3D

var target_position: Vector3 = Vector3.ZERO  # Position to move towards
var current_job: String = ""
var current_bush: Bush
var at_target: bool = false
var working: bool = false
var navigating: bool = false;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const HARVEST_COOLDOWN = 1.0
var harvest_cooldown = HARVEST_COOLDOWN

var working_timer : Timer = Timer.new()

func _ready():
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	nav_agent.target_reached.connect(Callable(_on_reach_target))
	add_child(working_timer)

func _physics_process(delta: float) -> void:
	if current_job == "harvest" and not nav_agent.is_navigation_finished() and not at_target and navigating:
		move_toward_target(delta)
	
	if at_target and not working:
		print("starting harvest timer")
		working_timer.one_shot = false
		working_timer.autostart = false
		working_timer.wait_time = HARVEST_COOLDOWN
		working_timer.timeout.connect(try_harvest)
		working_timer.start()
		working = true
		
func move_toward_target(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func set_target_position(pos: Vector3) -> void:
	if nav_agent:
		print("Setting colony member target position: ", pos)
		at_target = false
		navigating = true
		nav_agent.set_target_position(pos)
		target_position = pos
	else:
		push_error("NavigationAgent not set!")

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	if navigating:
		move_and_slide()

func _on_reach_target() -> void:
	print("Reached target!")
	navigating = false
	at_target = true

func try_harvest():
	if current_job != "harvest":
		return
	if current_bush and current_bush.harvest_stick():
		print("Stick harvested!")
		# set timer for some time to try to harvest again
	else:
		print("No more sticks!")
		current_job = ""  # Clear job after harvesting
		at_target = false # no longer at target
		working = false
		navigating = false
		working_timer.stop()
		working_timer.timeout.disconnect(try_harvest)

func start_moving_to_target(pos: Vector3) -> void:
	print("Starting movement to: ", pos)
	current_job = "harvest"
	at_target = false
	set_target_position(pos)

func _on_path_changed():
	print("Path changed. New path length: ", nav_agent.get_current_navigation_path().size())

func _on_target_reached():
	print("Target reached signal received")

func cleanup_current_job():
	# todo maybe disconnect all timeouts from working timer
	if current_job == "harvest":
		at_target = false # no longer at target
		working = false
		working_timer.stop()
		if working_timer.is_connected("timeout", try_harvest):
			working_timer.timeout.disconnect(try_harvest)

func assign_harvest_job(target: Vector3, bush: Bush):
	cleanup_current_job()
	at_target = false
	set_target_position(target)
	current_bush = bush
	current_job = "harvest"
