extends Node3D

@export var alien_scene: PackedScene
@export var player_body: Node3D       # XRToolsPlayerBody
@export var player_camera: XRCamera3D # XRCamera3D for tracking
var alien: Node3D = null
var shooter_enabled := false

const SPAWN_RADIUS := 100.0

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
	var angle := randf() * TAU
	var offsetx := cos(angle) * SPAWN_RADIUS
	var offsetz := sin(angle) * SPAWN_RADIUS

	alien.global_transform.origin = Vector3(p.x + offsetx, p.y, p.z + offsetz)

	alien.player = player_camera      # movement target
	alien.player_body = player_body   # collision target
	alien.manager = self

func alien_killed():
	_play_hurt_sound()
	_spawn_alien()
	

func player_touched():
	if alien and alien.has_node("HurtSound"):
		alien.get_node("HurtSound").play()

	alien_killed()

func _kill_current():
	if alien:
		alien.queue_free()
		alien = null
		
func _play_hurt_sound():
	if not alien:
		return

	var sound: AudioStreamPlayer2D = alien.hurtsound
	if sound:

		# Detach so it can keep playing after alien is freed
		sound.get_parent().remove_child(sound)
		get_tree().current_scene.add_child(sound)

		sound.play()

		# Remove sound when finished
		sound.finished.connect(func(): sound.queue_free())
