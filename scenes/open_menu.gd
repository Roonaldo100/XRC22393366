extends XRController3D

@export var menu : Node3D
@export var cam : XRCamera3D

func _ready() -> void:
	if !menu:
		push_error("need to assign the menu export")
		return
	if !cam:
		push_error("need to assign the camera export")
		return
		
	


func _on_button_pressed(name: String) -> void:
	if name == "ax_button":
		print("Pressed A")
		#Put the menu in front of the player's face
		#var forward := -cam.global_transform.basis.z
		#menu.global_transform.origin = cam.global_transform.origin + forward * 1.5
		#menu.look_at(cam.global_transform.origin, Vector3.UP)
		#menu.visible = true
		if not SolarSettings.orbit_paused:
			SolarSettings.orbit_paused = true
		else:
			SolarSettings.orbit_paused = false
		
