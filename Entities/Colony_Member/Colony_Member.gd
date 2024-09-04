class_name ColonyMember extends CharacterBody3D
@export var speed: float = 10.0  # Movement speed
@export var nav_agent: NavigationAgent3D
@onready var colony_member_text_label: Text_3D = %State_Label
@onready var work_search_timer: Timer = %WorkSearchingTimer
@onready var inventory_label: Text_3D = %Inventory_Label

var inventory: Inventory = Inventory.new()

var target_position: Vector3 = Vector3.ZERO  # Position to move towards
var current_job: String = ""
var current_bush: Bush
var at_target: bool = false
var working: bool = false
var navigating: bool = false;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const HARVEST_COOLDOWN = 0.5
var harvest_cooldown = HARVEST_COOLDOWN

var working_timer : Timer = Timer.new()

const MIN_STUCK_MOVEMENT = .01
const LAST_POSITIONS_NUM = 10
var last_positions_buf: Circular_Buffer = Circular_Buffer.new(LAST_POSITIONS_NUM)

var exclude_list = []

func _ready():
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	nav_agent.target_reached.connect(Callable(_on_reach_target))
	add_child(working_timer)
	set_idle()

func set_idle():
	colony_member_text_label.Set_3D_Text("idle")
	current_job = ""  # Clear job after harvesting
	at_target = false # no longer at target
	working = false
	navigating = false
	work_search_timer.start()

func _physics_process(_delta: float) -> void:
	if current_job == "harvest" and not nav_agent.is_navigation_finished() and not at_target and navigating:
		if current_bush.is_claimed_by_other(get_instance_id()):
			set_idle()
		move_toward_target()
	
	if at_target and not working:
		
		working_timer.one_shot = false
		working_timer.autostart = false
		if current_job == "harvest":
			#print("starting harvest timer")
			working_timer.wait_time = HARVEST_COOLDOWN
			working_timer.timeout.connect(try_harvest)
			working_timer.start()
			colony_member_text_label.Set_3D_Text("harvesting sticks")
			working = true
		
func move_toward_target() -> void:
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	#remember last N positions, to get unstuck if not moving
	last_positions_buf.add_item(global_position)
	if last_positions_buf.buff_saturated():
		if last_positions_buf.all(func(element): return abs(element - global_position).length() < MIN_STUCK_MOVEMENT):
			print("marking worker as stuck new method")
			exclude_list.append(current_bush)
			work_complete()
			last_positions_buf = Circular_Buffer.new(LAST_POSITIONS_NUM)
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func set_target_position(pos: Vector3) -> void:
	if nav_agent:
		work_search_timer.stop()
		at_target = false
		navigating = true
		colony_member_text_label.Set_3D_Text("navigating")
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
	
	#init exclude list as we reached some work
	exclude_list = []

func try_harvest():
	if current_job != "harvest":
		return
	if current_bush and current_bush.harvest_stick():
		current_bush.mark_working(get_instance_id())
		inventory.add_inventory_item("bush")
		inventory_label.Set_3D_Text(str(inventory.get_number_item("bush")))
		# set timer for some time to try to harvest again
	else:
		work_complete()

func start_moving_to_target(pos: Vector3) -> void:
	
	print("Starting movement to: ", pos)
	current_job = "harvest"
	at_target = false
	set_target_position(pos)

func _on_path_changed():
	print("Path changed. New path length: ", nav_agent.get_current_navigation_path().size())

func _on_target_reached():
	print("Target reached signal received")
	
func assign_harvest_job(target: Vector3, bush: Bush):
	if current_bush:
		current_bush.done_working()
	work_complete()
	at_target = false
	set_target_position(target)
	current_bush = bush
	current_job = "harvest"

func work_complete():
	set_idle()
	working_timer.stop()
	for connection in working_timer.get_signal_connection_list("timeout"):
		working_timer.timeout.disconnect(connection.callable)
	
	#enable work search timer again
	work_search_timer.start()
	
func find_closest_node_with_work(center: Vector3, radius: float, excluded_nodes: Array) -> Node3D:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	query.shape = SphereShape3D.new()
	query.shape.radius = radius
	query.transform.origin = center
	
	var result = space_state.intersect_shape(query, 1024)

	var closest_node: Node3D = null
	var closest_distance: float = INF

	for collision in result:
		var node = collision.collider as Node3D
		if node and node.has_method("has_work") and node.has_work() && node not in excluded_nodes:
			var distance = center.distance_to(node.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_node = node

	return closest_node  # Return the closest node found, or null if none is found

	
func _on_work_searching_timer_timeout() -> void:
	# search area and make list of all nodes that have has_work()
	# find closest that returns true and assign that
	var closest_node = find_closest_node_with_work(global_position, 10, exclude_list)
	if closest_node:
		print("Found work")
		if closest_node is Bush:
			assign_harvest_job(closest_node.global_position,closest_node)
			closest_node.mark_working(get_instance_id())

	


func _on_exclude_clear_timer_timeout() -> void:
	print("clearing exclude list")
	exclude_list = []
