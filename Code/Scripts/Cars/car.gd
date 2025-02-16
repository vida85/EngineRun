extends Node3D

@export var car_scene: PackedScene
var car_instance: CharacterBody3D

@export_group("Start & Stop Locations")
@export var start_marker: Marker3D
@export var stop_marker: Marker3D

@export_group("Testing System")
@export var wait: float = 3.0
@export var test: bool

@onready var front_wheel_control: Node3D
@onready var back_wheel_control: Node3D
@onready var honk: AudioStreamPlayer3D

const WHEEL_RADIUS: float = .1
const SPEED: float = .75

var _moving: bool = false
var last_position: Vector3
var move_direction: Vector3


func _ready():
	if car_scene:
		car_instance = car_scene.instantiate()
		add_child(car_instance)
		front_wheel_control = car_instance.find_child("FrontWheelControl")
		back_wheel_control = car_instance.find_child("BackWheelControl")
		honk = car_instance.find_child("Honk")

	position = start_marker.global_position 
	last_position = position

	# Calculate movement direction from start to stop
	move_direction = (stop_marker.global_position - start_marker.global_position).normalized()
	look_at(move_direction)
	
	if test:
		await get_tree().create_timer(wait).timeout
		_moving = true
		honk.play()


func _process(delta: float) -> void:
	if _moving:
		# Move in the precomputed direction
		car_instance.velocity = move_direction * SPEED
		car_instance.move_and_slide()

		# Check if the car has passed the stop marker
		var to_stop_marker = stop_marker.global_position - car_instance.global_position
		if move_direction.dot(to_stop_marker) <= 0:  # If past the stop marker
			_moving = false
			car_instance.velocity = Vector3.ZERO

		# Calculate actual distance moved
		var distance_traveled = car_instance.global_position.distance_to(last_position)
		last_position = car_instance.global_position

		# Rotate wheels based on distance traveled
		var rotation_amount = distance_traveled / WHEEL_RADIUS
		front_wheel_control.rotate_y(rotation_amount/2)
		back_wheel_control.rotate_y(rotation_amount/2)
	else:
		return
