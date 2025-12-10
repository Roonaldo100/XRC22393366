extends Node3D

@export var viewport_2d : XRToolsViewport2DIn3D   # Drag your Menu (Viewport2DIn3D) here
var ui_root : Control
var buttons : Array[BaseButton] = []
var current_index : int = 0

var menu_open : bool = false
var move_cooldown := 0.2
var move_timer := 0.0


func _ready() -> void:
	# Delay init until XRTools loads the Viewport content
	call_deferred("_init_ui")


# -------------------------------
#  INITIALIZE UI INSIDE VIEWPORT
# -------------------------------
func _init_ui() -> void:
	if viewport_2d == null:
		push_error("MenuNavigation: viewport_2d export is NOT set!")
		return

	var vp := viewport_2d.get_viewport()
	if vp == null:
		push_error("MenuNavigation: SubViewport could not be retrieved.")
		return

	if vp.get_child_count() == 0:
		push_error("MenuNavigation: UI scene did NOT load. Check XRToolsViewport2DIn3D → Scene property.")
		return

	ui_root = vp.get_child(0)  # CanvasLayer → your UI root
	print("MenuNavigation: UI Root =", ui_root)

	buttons = ui_root.get_tree().get_nodes_in_group("menu_buttons")

	if buttons.is_empty():
		push_error("MenuNavigation: No buttons found in group 'menu_buttons'!")
		return

	# Highlight the first button
	_highlight_button(0)
	print("MenuNavigation: Buttons detected =", buttons)


# ------------------------------------
#  EXTERNAL CONTROL (called from A button on controller)
# ------------------------------------
func open_menu():
	menu_open = true
	visible = true
	print("Menu opened")


func close_menu():
	menu_open = false
	visible = false
	print("Menu closed")


# -------------------------------
#  MAIN UPDATE LOOP
# -------------------------------
func _process(delta: float) -> void:
	if not menu_open:
		return

	move_timer -= delta

	var controller := _get_right_controller()
	if controller == null:
		return

	var input := controller.get_vector2("primary")

	# Navigation Up/Down
	if input.y < -0.5 and move_timer <= 0.0:
		_move_selection(-1)
	if input.y > 0.5 and move_timer <= 0.0:
		_move_selection(1)

	# Activate button with A
	if controller.is_button_pressed("ax_button"):
		_activate_button()


func _move_selection(direction: int):
	current_index = (current_index + direction) % buttons.size()
	_highlight_button(current_index)
	move_timer = move_cooldown


func _highlight_button(idx: int):
	for i in buttons.size():
		var b := buttons[i]

		if i == idx:
			# Highlight selected button
			b.add_theme_color_override("font_color", Color.YELLOW)
			b.add_theme_color_override("panel", Color(0.3, 0.3, 0.05))
		else:
			# Normal button
			b.add_theme_color_override("font_color", Color.WHITE)
			b.add_theme_color_override("panel", Color(0.1, 0.1, 0.1))


func _activate_button():
	var b := buttons[current_index]
	print("Button pressed:", b.name)
	b.emit_signal("pressed")  # fire the button's action


# -------------------------------
#  HELPER: GET CONTROLLER
# -------------------------------
func _get_right_controller() -> XRController3D:
	var player := get_tree().root.get_node("SolarSystemRoot/Player")
	if player == null:
		return null

	return player.get_node_or_null("XROrigin3D/RightHand") as XRController3D
