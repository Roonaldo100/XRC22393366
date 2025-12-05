extends Node3D

@export var rotation_period_relative_to_earth: float = 1.0  # Earth = 1
@export var axial_tilt_deg: float = 0.0
@export var spin_direction: int = 1        # 1 normal, -1 retrograde
@export var base_spin_multiplier: float = 1.0

var added_spin_velocity := 0.0


func _ready():
	rotation_degrees.x = axial_tilt_deg


func _process(delta):
	# Automatic planetary rotation
	var spin_speed = (base_spin_multiplier * (1.0 / rotation_period_relative_to_earth))

	# Add user imparted spin
	if added_spin_velocity != 0.0:
		spin_speed += added_spin_velocity
		added_spin_velocity = lerp(added_spin_velocity, 0.0, delta * 1.5)

	rotate_y(spin_direction * spin_speed * delta)
