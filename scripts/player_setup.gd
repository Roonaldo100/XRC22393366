extends Node3D

@onready var player_body := $XROrigin3D/PlayerBody

func _ready():
	player_body.gravity = Vector3.ZERO
