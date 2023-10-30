extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var fov = 75
@onready var camera_3d = $Head/Camera3D


const mouse_sensitivity = 0.004

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(event.relative.x * -mouse_sensitivity) # change this to turn the character the direction they are moving
		$Head.rotate_x(event.relative.y * -mouse_sensitivity)
		$Head.rotation.x = clamp($Head.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# if velocity != Vector3.ZERO:
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
