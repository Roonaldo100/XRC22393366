extends Node3D

var player: Node3D        # XRCamera3D for tracking
var player_body: Node3D   # XRToolsPlayerBody for collision
var manager
var speed := 10.0
@onready var hurtsound = $Area3D/HurtSound

func _process(delta):
	if not player:
		return

	var pos = global_transform.origin
	var target = player.global_transform.origin

	var dir = (target - pos).normalized()
	pos += dir * speed * delta

	global_transform.origin = pos

func die():
	manager.alien_killed()
	queue_free()
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player_body:
		manager.player_touched()
		queue_free()
