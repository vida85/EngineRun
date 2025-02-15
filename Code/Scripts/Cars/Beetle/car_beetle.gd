extends CharacterBody3D

@export_group("Start & Stop Locations")
@export var start_marker: Marker3D
@export var stop_marker: Marker3D

@export_group("Testing System")
@export var wait: float = 3.0
@export var test: bool

@onready var front_wheel_control: Node3D = %FrontWheelControl
@onready var back_wheel_control: Node3D = %BackWheelControl
@onready var honk: AudioStreamPlayer3D = $Honk

const WHEEL_RADIUS: float = .1
const SPEED: float = .5

var _moving: bool = false
var last_position: Vector3
var move_direction: Vector3




func _ready():
    position = start_marker.position 
    last_position = position

    # Calculate movement direction from start to stop
    move_direction = (stop_marker.position - start_marker.position).normalized()
    if test:
        await get_tree().create_timer(wait).timeout
        _moving = true
        honk.play()


func _process(delta: float) -> void:
    if _moving:
        # Move in the precomputed direction
        velocity = move_direction * SPEED
        move_and_slide()

        # Check if the car has passed the stop marker
        var to_stop_marker = stop_marker.position - position
        if move_direction.dot(to_stop_marker) <= 0:  # If past the stop marker
            _moving = false
            velocity = Vector3.ZERO

        # Calculate actual distance moved
        var distance_traveled = position.distance_to(last_position)
        last_position = position

        # Rotate wheels based on distance traveled
        var rotation_amount = distance_traveled / WHEEL_RADIUS
        front_wheel_control.rotate_y(rotation_amount)
        back_wheel_control.rotate_y(rotation_amount)
    else:
        return
