extends Node3D

@export var alien_scene: PackedScene
@export var player_body: Node3D       # XRToolsPlayerBody
@export var player_camera: XRCamera3D # XRCamera3D for tracking
var alien: Node3D = null
var shooter_enabled := false

func toggle_shooter():
	shooter_enabled = !shooter_enabled

	if shooter_enabled:
		_spawn_alien()
		print("alien on")
	else:
		_kill_current()
		print("alien off")

func _spawn_alien():
	_kill_current()

	alien = alien_scene.instantiate()
	get_tree().current_scene.add_child(alien)

	var p = player_camera.global_transform.origin
	var spawn_z = -100.0

	alien.global_transform.origin = Vector3(p.x, p.y, p.z + spawn_z)

	alien.player = player_camera      # movement target
	alien.player_body = player_body   # collision target
	alien.manager = self

func alien_killed():
	_spawn_alien()

func player_touched():
	if alien and alien.has_node("HurtSound"):
		alien.get_node("HurtSound").play()

	alien_killed()

func _kill_current():
	if alien:
		alien.queue_free()
		alien = null
