extends CharacterBody3D


const SPEED = 30.0
const JUMP_VELOCITY = 4.5
const FRICTION = 0.5

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed:
			velocity.y = SPEED * %Land_Raycast.get_collision_point().distance_to(global_position)/8
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && event.pressed:
			velocity.y = -SPEED * %Land_Raycast.get_collision_point().distance_to(global_position)/8

func _physics_process(_delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	velocity.y = lerp(velocity.y, 0.0, .1)
	move_and_slide()
