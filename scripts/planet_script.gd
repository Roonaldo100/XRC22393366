extends Node3D

# EARTH REFERENCE VALUES 
const EARTH_RADIUS := 5.0
const EARTH_ROTATION_SPEED := 1.0      # Earth day
const SUN_Z_POSITION := 6000.0
const SUN_SCALE := 545.0               # Godot radius of the Sun
const ORBIT_SCALE := 15.00

#  PLANET DATA 
const PLANET_DATA := {
	"Sun": {
		"scale_ratio": 109.0,
		"rotation_period": 27.0,
		"distance": 0.0,
		"orbital_period": 0.0
	},
	"Mercury": {
		"scale_ratio": 0.38, #Compared to Earth
		"rotation_period": 58.6, #Earth days to rotate on axis
		"distance": 57.91, #From Sun in million KM
		"orbital_period": 88.0 #Earth days toorbit Sun
	},
	"Venus": {
		"scale_ratio": 0.95,
		"rotation_period": 243.0,
		"distance": 108.2,
		"orbital_period": 225.0
	},
	"Earth": {
		"scale_ratio": 1.0,
		"rotation_period": 1.0,
		"distance": 149.6,
		"orbital_period": 365.0
	},
	"Mars": {
		"scale_ratio": 0.53,
		"rotation_period": 1.03,
		"distance": 227.9,
		"orbital_period": 687.0
	},
	"Jupiter": {
		"scale_ratio": 11.21,
		"rotation_period": 0.41,
		"distance": 778.5,
		"orbital_period": 4333.0
	},
	"Saturn": {
		"scale_ratio": 9.45,
		"rotation_period": 0.44,
		"distance": 1434.0,
		"orbital_period": 10759.0
	},
	"Uranus": {
		"scale_ratio": 4.01,
		"rotation_period": 0.72,
		"distance": 2871.0,
		"orbital_period": 30687.0
	},
	"Neptune": {
		"scale_ratio": 3.88,
		"rotation_period": 0.67,
		"distance": 4495.0,
		"orbital_period": 60190.0
	}
}

# RUNTIME VALUES 
var rotation_speed := 1.0
var orbit_angle := 0.0
var orbit_speed := 0.0
var orbit_radius := 0.0
var orbit_center := Vector3.ZERO


func _ready():
	var planet_name := name
	if not PLANET_DATA.has(planet_name):
		push_error("Planet data missing for " + planet_name)
		return
	
	var data : Dictionary = PLANET_DATA[planet_name]

	var scale_ratio : float = data["scale_ratio"]
	var rotation_period : float = data["rotation_period"]
	var distance_million_km : float = data["distance"]
	var orbital_period_days : float = data["orbital_period"]

	# RADIUS / SCALE
	var radius := EARTH_RADIUS * scale_ratio
	scale = Vector3.ONE * radius

	# AXIAL ROTATION
	rotation_speed = EARTH_ROTATION_SPEED / rotation_period

	#  ORBITAL PARAMETERS 
	if planet_name != "Sun":
		var sun_radius := SUN_SCALE
		orbit_center = Vector3(0, 0, SUN_Z_POSITION)

		# surface to surface distance stays constant:
		# total radial distance:
		orbit_radius = sun_radius + distance_million_km + radius

		# orbital angular speed:
		# complete orbit in (orbital_period_days / 15) seconds
		var orbit_duration := orbital_period_days / ORBIT_SCALE   # seconds per full orbit
		orbit_speed = (TAU / orbit_duration)               # radians per second

		# starting angle = 0 → starting z placement matches earlier behavior
		position = orbit_center + Vector3(0, 0, -orbit_radius)
		position.y = radius
	else:
		# The sun doesn’t orbit anything
		position = Vector3(0, radius, SUN_Z_POSITION)

	print("Configured ", planet_name,
		" | scale=", radius,
		" | rotation_speed=", rotation_speed,
		" | orbit_speed=", orbit_speed,
		" | orbit_radius=", orbit_radius)


func _process(delta):
	# ---- AXIAL SPIN ----
	rotate_y(rotation_speed * delta)

	# ---- ORBITAL MOTION ----
	if orbit_speed != 0.0:
		orbit_angle += orbit_speed * delta

		# circle around the Sun in XZ plane
		var x := orbit_center.x + orbit_radius * sin(orbit_angle)
		var z := orbit_center.z - orbit_radius * cos(orbit_angle)

		position.x = x
		position.z = z
