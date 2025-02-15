extends Node3D

@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@export var start_position: Marker3D
@export var end_position: Marker3D
var day: bool = true


func _ready() -> void:
    directional_light_3d.global_rotation = start_position.global_rotation
    
func _process(delta: float) -> void:
    directional_light_3d.global_rotation = directional_light_3d.global_rotation.lerp(end_position.global_rotation, .02 * delta)
    
        
