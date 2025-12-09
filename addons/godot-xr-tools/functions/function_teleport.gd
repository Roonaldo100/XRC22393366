@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsFunctionTeleport
extends Node3D

const DEFAULT_MASK := 0b1111_1111_1111_1111_1111_1111_1111_1111
const _DefaultMaterial := preload("res://addons/godot-xr-tools/materials/capsule.tres")

@export var enabled : bool = true: set = set_enabled
@export var teleport_button_action : String = "trigger_click"

@export_group("Visuals")
@export var can_teleport_color : Color = Color(0.0, 1.0, 0.0, 1.0)
@export var cant_teleport_color : Color = Color(1.0, 0.0, 0.0, 1.0)
@export var no_collision_color : Color = Color(45.0/255.0, 80.0/255.0, 220.0/255.0, 1.0)

@export var target_texture : Texture2D = preload("res://addons/godot-xr-tools/images/teleport_target.png") : set = set_target_texture

@export_group("Player")
@export var player_height : float = 1.8: set = set_player_height
@export var player_radius : float = 0.4: set = set_player_radius
@export var player_scene : PackedScene: set = set_player_scene

@export_group("Collision")
@export_flags_3d_physics var collision_mask : int = 1023
@export_flags_3d_physics var valid_teleport_mask : int = DEFAULT_MASK

var player_material : StandardMaterial3D = _DefaultMaterial : set = set_player_material

var is_teleporting : bool = false
var can_teleport : bool = false
var last_target_transform : Transform3D = Transform3D()
var prev_button_down := false

var player : Node3D
var collision_shape : Shape3D

@onready var ws : float = XRServer.world_scale
@onready var capsule : MeshInstance3D = $Target/Player_figure/Capsule
@onready var player_body := XRToolsPlayerBody.find_instance(self)
@onready var controller := XRHelpers.get_xr_controller(self)


func _ready():
	# turn teleport mesh into a visible cylinder beam
	var laser := CylinderMesh.new()
	laser.top_radius = 0.02
	laser.bottom_radius = 0.02
	laser.height = 1.0

	$Teleport.mesh = laser
	$Teleport.visible = false

	# ensure it has a material before scaling
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1, 0, 0)
	mat.albedo_color = Color(1, 0, 0)
	$Teleport.set_surface_override_material(0, mat)


func _physics_process(delta):
	if Engine.is_editor_hint() or !player_body or !controller:
		return

	if !enabled:
		is_teleporting = false
		$Target.visible = false
		$Teleport.visible = false
		return

	var button_down := controller.is_button_pressed(teleport_button_action)
	var button_just_pressed := button_down and not prev_button_down
	var button_just_released := not button_down and prev_button_down
	prev_button_down = button_down

	if button_just_pressed:
		is_teleporting = true
		$Target.visible = false
		$Teleport.visible = true


	# UPDATE LASER WHILE HOLDING
	if is_teleporting and button_down:
		var origin := controller.global_transform.origin
		var forward := controller.global_transform.basis.z.normalized()

		# very long-range ray
		var state := get_world_3d().direct_space_state
		var ray_query := PhysicsRayQueryParameters3D.new()
		ray_query.from = origin
		ray_query.to = origin + forward * -5000.0   # <<< LONG RANGE >>>
		ray_query.collision_mask = collision_mask
		ray_query.exclude = [player_body]

		var result := state.intersect_ray(ray_query)

		if not result.is_empty():
			var hit_pos: Vector3 = result.position

			# update target indicator
			last_target_transform.origin = hit_pos + Vector3.UP * 0.05
			last_target_transform.basis = Basis()
			$Target.visible = true
			$Target.global_transform = last_target_transform

			# CAN TELEPORT
			can_teleport = true
			$Target.get_surface_override_material(0).albedo_color = can_teleport_color
			_set_laser(origin, hit_pos, can_teleport_color)

		else:
			# NO VALID HIT — show long beam pointing outward
			can_teleport = false
			$Target.visible = false
			var far_point := origin + forward * -2000.0
			_set_laser(origin, far_point, cant_teleport_color)


	# TELEPORT ON RELEASE 
	if button_just_released and is_teleporting:
		if can_teleport:
			var new_transform := last_target_transform
			new_transform.basis.y = player_body.up_player
			new_transform.basis.x = new_transform.basis.y.cross(new_transform.basis.z).normalized()
			new_transform.basis.z = new_transform.basis.x.cross(new_transform.basis.y).normalized()
			player_body.teleport(new_transform)

		# shutdown visuals
		is_teleporting = false
		can_teleport = false
		$Teleport.visible = false
		$Target.visible = false


# LASER BEAM APPEARANCE

func _set_laser(origin: Vector3, hit_pos: Vector3, color: Color) -> void:
	var dist := origin.distance_to(hit_pos)

	# direction
	var direction := (hit_pos - origin).normalized()

	# basis that looks forward
	var aim_basis := Basis().looking_at(direction, Vector3.UP)

	# rotate mesh so cylinder's height axis (+Y) aligns with forward axis (-Z)
	var rot_basis := Basis(Vector3(1, 0, 0), -PI / 2)

	# apply orientation
	var laser_transform := Transform3D()
	laser_transform.basis = aim_basis * rot_basis
	laser_transform.origin = origin
	$Teleport.global_transform = laser_transform

	# set beam length by changing cylinder height 
	var laser_mesh: CylinderMesh = $Teleport.mesh
	laser_mesh.height = dist

	# update color
	var mat: StandardMaterial3D = $Teleport.get_surface_override_material(0)
	mat.emission = color * 3.0
	mat.albedo_color = color

	$Teleport.visible = true


func set_enabled(new_val: bool) -> void:
	enabled = new_val
	if enabled:
		set_physics_process(true)

func set_target_texture(tex: Texture2D) -> void:
	target_texture = tex
	if is_inside_tree():
		_update_target_texture()

func set_player_height(v: float) -> void:
	player_height = v
	if is_inside_tree():
		_update_player_height()

func set_player_radius(v: float) -> void:
	player_radius = v
	if is_inside_tree():
		_update_player_radius()

func set_player_scene(s: PackedScene) -> void:
	player_scene = s
	notify_property_list_changed()
	if is_inside_tree():
		_update_player_scene()

func set_player_material(m: StandardMaterial3D) -> void:
	player_material = m
	if is_inside_tree():
		_update_player_material()

func _update_target_texture():
	var material : StandardMaterial3D = $Target.get_surface_override_material(0)
	if material and target_texture:
		material.albedo_texture = target_texture

func _update_player_height():
	if collision_shape:
		collision_shape.height = player_height - (2.0 * player_radius)
	if capsule:
		capsule.mesh.height = player_height
		capsule.position = Vector3(0.0, player_height / 2.0, 0.0)

func _update_player_radius():
	if collision_shape:
		collision_shape.height = player_height
		collision_shape.radius = player_radius
	if capsule:
		capsule.mesh.height = player_height
		capsule.mesh.radius = player_radius

func _update_player_scene():
	if player:
		player.queue_free()
		player = null
	if player_scene:
		player = player_scene.instantiate()
		$Target/Player_figure.add_child(player)
	capsule.visible = player == null

func _update_player_material():
	if player_material:
		capsule.set_surface_override_material(0, player_material)
