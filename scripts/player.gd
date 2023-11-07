extends CharacterBody3D



const SPEED = 16.0 # speed: default 8.0
const JUMP_VELOCITY = 6.0 # the velocity to jump one block
const ACCELERATION = 2.0
var jump_height = 3 # number of blocks to jump

@export var fov = 75
@onready var camera_3d = $Neck/Head/Camera3D
@onready var raycast = $Neck/Head/Camera3D/RayCast3D
@onready var block_outline = $MeshInstance3D

signal place_block(pos, t)
signal break_block(pos)

var camera_distance: float
var zoom_speed: float = 1

var first_person: bool = false

const mouse_sensitivity = 0.004

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#var gravity = 0

func _ready():
	camera_distance = camera_3d.get_distance()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	$MeshInstance3D.scale = Vector3(scale.x*2/3+.1, scale.y*2/3+.1, scale.z*2/3+.1)

func _input(event): # create states, such as build mode, combat mode, and first person mode
	if Input.is_action_just_pressed("view change"):
		first_person = !first_person
		if !first_person:
			camera_3d.set_distance(camera_distance)
	if !first_person:
		if Input.is_action_pressed("right-click"):
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.is_action_just_pressed("zoom out"):
			camera_distance = camera_3d.set_distance(camera_3d.get_distance() + zoom_speed)
		if Input.is_action_just_pressed("zoom in"):
			camera_distance = camera_3d.set_distance(camera_3d.get_distance() - zoom_speed)
	else:
		if camera_3d.get_distance() != 0:
			camera_3d.set_distance(0, true)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# camera should see through walls only to make the surroundings of the player visible
		$Neck/Head.rotate_x(event.relative.y * -mouse_sensitivity)
		$Neck.rotate_y(event.relative.x * -mouse_sensitivity)
		$Neck/Head.rotation.x = clamp($Neck/Head.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY * sqrt(jump_height)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = ($Neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir: # If you are trying to move the character, move them in accordance to the directional input related to the camera
		var lookdir = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, lookdir, 0.3)
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	var camera_ray_from = camera_3d.project_ray_origin(mouse_pos)
	var camera_ray_to = camera_3d.project_local_ray_normal(mouse_pos)
	
	raycast.global_position = camera_ray_from
	raycast.target_position = camera_ray_to * 1000
	
	if raycast.is_colliding():
		
		var norm = raycast.get_collision_normal()
		var pos = raycast.get_collision_point()
		
		var blockx = floor(pos.x) +.5
		var blocky = floor(pos.y) +.5
		var blockz = floor(pos.z) +.5
		var blockpos = Vector3(blockx, blocky, blockz)
		
		block_outline.global_position = blockpos
		block_outline.visible = true
	else:
		block_outline.visible = false
		
