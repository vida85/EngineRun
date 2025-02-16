extends CharacterBody3D

signal grab_direction(direction: Vector3)

@onready var mechanic_boy: Node3D = $mechanic_man
@onready var animation_player: AnimationPlayer = $mechanic_man/AnimationPlayer
@onready var foot_step: AudioStreamPlayer3D = $FootStep

@export_group("Player Camera")
@export var camera: Camera3D

@export_group("Player Settings")
@export var walk: float = .25
@export var run: float = .4
@export var sfx_volume: float = -12.0

var camera_offset: Vector3
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	animation_player.current_animation = "idle"
	camera_offset = camera.global_position
	foot_step.volume_db = sfx_volume


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Apply movement speed to the direction.
	if direction != Vector3.ZERO:
		var speed:= walk if not Input.is_action_pressed("run") else run
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		grab_direction.emit(direction)
		# Calculate the target rotation.
		var target_rotation_y = atan2(-velocity.x, -velocity.z)

		# Interpolate rotation.y towards the target using the shortest path.
		rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 10)

	else:
		# Smoothly decelerate when no input is detected.
		velocity.x = move_toward(velocity.x, 0, walk)
		velocity.z = move_toward(velocity.z, 0, walk)

	animate_character(direction)
	move_and_slide()
	
	camera.global_position = global_position + camera_offset/2


func animate_character(direction):
	if is_on_floor():
		if direction != Vector3.ZERO:
			if animation_player.current_animation != "walk":
				animation_player.current_animation = "walk"
		elif animation_player.current_animation != "idle":
			animation_player.current_animation = "idle"
	else:
		pass
	animation_player.play()


func play_foot_step():
	foot_step.pitch_scale = randf_range(.8, 1.0)
	foot_step.play()
	


			
