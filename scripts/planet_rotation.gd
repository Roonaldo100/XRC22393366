extends Node3D

# Earth reference values
const EARTH_RADIUS := 5.0              # Earth sphere radius in Godot
const EARTH_ROTATION_SPEED := 1.0      # Earth day = baseline
const SUN_Z_POSITION := 6000.0         # Sun location
const SUN_SCALE := 545.0               # Sun scale (radius in Godot units)

# Planet data
# format: { scale_ratio, rotation_period_relative_to_earth, distance_million_km }
const PLANET_DATA := {
	"Sun": {
		"scale_ratio": 109.0,     # Sun is 109× Earth diameter
		"rotation_period": 27.0,  # Approx average solar day
		"distance": 0.0
	},
	"Mercury": {
		"scale_ratio": 0.38,
		"rotation_period": 58.6,
		"distance": 57.91
	},
	"Venus": {
		"scale_ratio": 0.95,
		"rotation_period": 243.0,     # retrograde
		"distance": 108.2
	},
	"Earth": {
		"scale_ratio": 1.0,
		"rotation_period": 1.0,
		"distance": 149.6
	},
	"Mars": {
		"scale_ratio": 0.53,
		"rotation_period": 1.03,
		"distance": 227.9
	},
	"Jupiter": {
		"scale_ratio": 11.21,
		"rotation_period": 0.41,
		"distance": 778.5
	},
	"Saturn": {
		"scale_ratio": 9.45,
		"rotation_period": 0.44,
		"distance": 1434.0
	},
	"Uranus": {
		"scale_ratio": 4.01,
		"rotation_period": 0.72,       # retrograde
		"distance": 2871.0
	},
	"Neptune": {
		"scale_ratio": 3.88,
		"rotation_period": 0.67,
		"distance": 4495.0
	}
}

var rotation_speed := 1.0

func _ready():
	var planet_name := name

	if not PLANET_DATA.has(planet_name):
		push_error("Planet data missing for " + planet_name)
		return

	var data: Dictionary[String, Variant] = PLANET_DATA[planet_name]


	# Extract values
	var scale_ratio: float = data["scale_ratio"]
	var rotation_period: float = data["rotation_period"]
	var distance_million_km: float = data["distance"]

	# Compute planet radius in Godot units
	var radius := EARTH_RADIUS * scale_ratio

	# 1) Apply scale
	scale = Vector3.ONE * radius

	# 2) Compute rotation speed
	rotation_speed = EARTH_ROTATION_SPEED / rotation_period

	# 3) Compute Z transform position
	var sun_radius := SUN_SCALE
	var z_pos := SUN_Z_POSITION - sun_radius - distance_million_km - radius
	position.z = z_pos

	print(
		"Configured ", planet_name,
		" | scale=", radius,
		" | rotation_speed=", rotation_speed,
		" | z=", z_pos
	)

func _process(delta):
	# Simple axial rotation
	rotate_y(rotation_speed * delta)
