extends Node3D

@export var alien_scene: PackedScene
@export var player: XRCamera3D
var alien: Node3D = null
var shooter_enabled := false


func toggle_shooter():
	if !shooter_enabled:
		shooter_enabled = true
	else:
		shooter_enabled = false

	if shooter_enabled:
		_spawn_alien()
	else:
		_kill_current()


func _spawn_alien():
	_kill_current()

	alien = alien_scene.instantiate()
	get_tree().current_scene.add_child(alien)

	var spawn_z = -100

	var p = player.global_transform.origin
	alien.global_transform.origin = Vector3(p.x, p.y, p.z + spawn_z)

	alien.player = player
	alien.manager = self


func alien_killed():
	_spawn_alien()


func player_touched():
	# Play hurt sound (if any)
	if alien and alien.has_node("HurtSound"):
		alien.get_node("HurtSound").play()

	alien_killed()


func _kill_current():
	if alien:
		alien.queue_free()
		alien = null
