extends Node3D

# Earth reference values
const SUN_Z_POSITION := 6000.0

@export var ORBIT_SCALE : float = 2.0    # Speed factor for all orbits

# Planet data
const PLANET_DATA := {
	"Sun": {"scale_ratio": 109.0, "rotation_period": 27.0, "distance": 0.0, "orbital_period": 0.0},
	"Mercury": {"scale_ratio": 0.38, "rotation_period": 58.6, "distance": 57.91, "orbital_period": 88.0},
	"Venus": {"scale_ratio": 0.95, "rotation_period": 243.0, "distance": 108.2, "orbital_period": 225.0},
	"Earth": {"scale_ratio": 1.0, "rotation_period": 1.0, "distance": 149.6, "orbital_period": 365.0},
	"Mars": {"scale_ratio": 0.53, "rotation_period": 1.03, "distance": 227.9, "orbital_period": 687.0},
	"Jupiter": {"scale_ratio": 11.21, "rotation_period": 0.41, "distance": 778.5, "orbital_period": 4333.0},
	"Saturn": {"scale_ratio": 9.45, "rotation_period": 0.44, "distance": 1434.0, "orbital_period": 10759.0},
	"Uranus": {"scale_ratio": 4.01, "rotation_period": 0.72, "distance": 2871.0, "orbital_period": 30687.0},
	"Neptune": {"scale_ratio": 3.88, "rotation_period": 0.67, "distance": 4495.0, "orbital_period": 60190.0}
}

# Each entry is a Dictionary with keys:
# "node", "rotation_speed", "orbit_speed", "orbit_radius", "orbit_angle", "orbit_center"
var planets : Array = []


func _ready():
	for child in get_children():
		if not PLANET_DATA.has(child.name):
			continue

		var data : Dictionary = PLANET_DATA[child.name]

		var scale_ratio : float = data["scale_ratio"]
		var rotation_period : float = data["rotation_period"]
		var distance_million_km : float = data["distance"]
		var orbital_period_days : float = data["orbital_period"]

		var radius : float = SolarSettings.earth_radius * scale_ratio
		(child as Node3D).scale = Vector3.ONE * radius

		var rotation_speed : float = SolarSettings.earth_rotation_speed / rotation_period

		var orbit_radius : float = 0.0
		var orbit_speed : float = 0.0
		var orbit_center : Vector3 = Vector3(0.0, 0.0, SUN_Z_POSITION)

		if child.name != "Sun":
			orbit_radius = SolarSettings.sun_scale + distance_million_km + radius
			var orbit_duration : float = orbital_period_days / SolarSettings.orbit_scale
			orbit_speed = TAU / orbit_duration

			var start_pos : Vector3 = orbit_center + Vector3(0.0, 0.0, -orbit_radius)
			start_pos.y = SolarSettings.sun_scale
			(child as Node3D).position = start_pos
		else:
			(child as Node3D).position = Vector3(0.0, radius, SUN_Z_POSITION)

		planets.append({
			"node": child,
			"rotation_speed": rotation_speed,
			"orbit_speed": orbit_speed,
			"orbit_radius": orbit_radius,
			"orbit_angle": 0.0,
			"orbit_center": orbit_center
		})


func _process(delta: float) -> void:
	for i in planets.size():
		var p : Dictionary = planets[i]
		var node : Node3D = p["node"]

		var rotation_speed : float = p["rotation_speed"]
		var orbit_speed : float = p["orbit_speed"]
		var orbit_radius : float = p["orbit_radius"]
		var orbit_angle : float = p["orbit_angle"]
		var orbit_center : Vector3 = p["orbit_center"]

		node.rotate_y(rotation_speed * delta)
		
		if SolarSettings.orbit_paused:
			continue

		if orbit_speed > 0.0:
			orbit_angle += orbit_speed * delta
			var angle : float = orbit_angle
			var r : float = orbit_radius
			var c : Vector3 = orbit_center

			var x : float = c.x + r * sin(angle)
			var z : float = c.z - r * cos(angle)

			var pos : Vector3 = node.position
			pos.x = x
			pos.z = z
			node.position = pos

			p["orbit_angle"] = orbit_angle
			planets[i] = p
