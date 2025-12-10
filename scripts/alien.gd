extends Node3D

var player: Node3D
var manager
var speed := 2.0

func _process(delta):
	if not player:
		return

	var pos = global_transform.origin
	var target = player.global_transform.origin  # follow the camera

	var dir = (target - pos).normalized()
	pos += dir * speed * delta

	global_transform.origin = pos

func die():
	manager.alien_killed()
	queue_free()

func _on_Area3D_body_entered(body):
	if body == player:
		manager.player_touched()
		queue_free()
