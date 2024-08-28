extends CharacterBody3D

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

@onready var flashlight = $CollisionShape3D/Camera3D/SpotLight3D
@onready var coll = $CollisionShape3D
@onready var ray = $CollisionShape3D/Camera3D/RayCast3D

var lock_dict = {
	0:false,
	1:false,
	2:false
}
var key_dict = {
	0:false,
	1:false,
	2:false
}

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var exitBool: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	
	_mouse_input = event is InputEventMouseMotion #and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

		
func _input(event):
	if event.is_action_pressed("exit"):
		exitBool=!exitBool
		if exitBool: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("FlashLight"):
		if flashlight.spot_range>=20: 
			flashlight.spot_range=0
		else: 
			flashlight.spot_range=24
			
	if event.is_action_pressed("Crouch"):
		if coll.scale.y<=0.5:
			coll.scale.y=1
		else:
			coll.scale.y=0.5
			
	if event.is_action_pressed("Interact") and ray.is_colliding():
		var obj = ray.get_collider().get_parent()
		var objParsed = obj as Key
		
		if objParsed == null : 
			objParsed = obj as Lock
			if objParsed!=null: #lock
				if key_dict[objParsed.Type]:
					lock_dict[objParsed.Type] = true
					objParsed.queue_free()
					#print(str(objParsed.Type)+" "+str(lock_dict[objParsed.Type]))
					
				if lock_dict.values().all(func(x): return x==true):
					print("todo abierto nomasss")
					%Gamemanager._retry()
				
		else: #key
			key_dict[objParsed.Type] = true
			objParsed.queue_free()
			#print(str(objParsed.Type)+" "+str(key_dict[objParsed.Type]))


func _update_camera(delta):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():

	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
	if not is_on_floor():
		velocity.y -= gravity*2 * delta
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right","Forward","Backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

	move_and_slide()
