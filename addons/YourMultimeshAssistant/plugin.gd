@tool
extends EditorPlugin

enum EVENT_MOUSE {
	EVENT_NONE,
	EVENT_MOVE,
	EVENT_CLICK,
}

const PASS_SIGNALS = "Signals"

var _raycast_3d : RayCast3D = null
var _cursor : Decal = null
var _marker : Decal = null
var _object_selected = null
var _position_draw := Vector3.ZERO
var _normal_draw := Vector3.ZERO
var _object_draw : Object = null
var _add_object := true : set = _on_set_add_object
var _select_object := false
var _choose_pos := false
var _control_menu = null
var tree : PopupMenu
var nodes2 = []
var _project_ray_origin := Vector3.INF
var _project_ray_normal := Vector3.INF
var _mouse_event := EVENT_MOUSE.EVENT_NONE
##This variable only exist because set_value_no_signal does not properly work on range nodes
##This will be replaced once that is fixed issue #70821 and #70834
var _no_signal := true
var _no_signal_timer = Time


func _enter_tree() -> void:
	add_autoload_singleton(PASS_SIGNALS, "res://addons/YourMultimeshAssistant/signals.gd")
	add_custom_type("YourMultimeshAssistant", "MultiMeshInstance3D", load("res://addons/YourMultimeshAssistant/mesh_instance.gd"), load("res://addons/YourMultimeshAssistant/YourMultimeshAssistant.svg"))
	_control_menu = load("res://addons/YourMultimeshAssistant/toolbar_alt.tscn").instantiate()
	_control_menu.visible = false
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _control_menu)
	tree = load("res://addons/YourMultimeshAssistant/tree.tscn").instantiate()
	get_window().call_deferred(StringName("add_child"), tree)
	_raycast_3d = RayCast3D.new()
	_raycast_3d.visible = false
	_cursor = Decal.new()
	_cursor.set_texture(Decal.TEXTURE_ALBEDO, load("res://addons/YourMultimeshAssistant/images/cursor.png"))
	_cursor.visible = false
	_marker = Decal.new()
	_marker.set_texture(Decal.TEXTURE_ALBEDO, load("res://addons/YourMultimeshAssistant/images/selected_marker.png"))
	_marker.visible = true
	_no_signal_timer = Timer.new()
	_no_signal_timer.one_shot = true
	_control_menu._add_btn.toggled.connect(_on_add_btn_toggle.bind(_control_menu._add_btn))
	_control_menu._select_btn.toggled.connect(_on_select_btn_toggle)
	_control_menu._aabb_center.toggled.connect(_on_set_aabb_center)
	_control_menu._mesh_normal.toggled.connect(_on_set_mesh_normal)
	_control_menu._pos_x_readout.value_changed.connect(_on_position_change)
	_control_menu._pos_y_readout.value_changed.connect(_on_position_change)
	_control_menu._pos_z_readout.value_changed.connect(_on_position_change)
	_control_menu._scale_slider.value_changed.connect(_on_scale_change)
	_control_menu._rotate_x_slider.value_changed.connect(_on_rotate_change)
	_control_menu._rotate_y_slider.value_changed.connect(_on_rotate_change)
	_control_menu._rotate_z_slider.value_changed.connect(_on_rotate_change)
	_control_menu._instance_select.value_changed.connect(_on_set_instance)
	_control_menu._choose_mesh.pressed.connect(get_selected_nodes.bind(self))
	_no_signal_timer.timeout.connect(_timer_timeout)
	tree.connect("id_pressed", _get_node_by_name)
	Signals.connect('_update_boxes', _update_readouts)
	Signals.connect('_set_marker', _add_marker)
	Signals.connect('_set_node_name', _generate_multimesh)
	add_child(_raycast_3d)
	add_child(_cursor)
	add_child(_marker)
	add_child(_no_signal_timer)
	remove_control_from_docks(_control_menu)

	
func _set_tree():
	_object_selected._on_set_scene_tree()


func _exit_tree() -> void:
	_raycast_3d.queue_free()
	_cursor.queue_free()
	_marker.queue_free()
	remove_control_from_docks(_control_menu)
	_control_menu.queue_free()
	remove_autoload_singleton(PASS_SIGNALS)
	remove_custom_type("YourMultimeshAssistant")


func _handles(object) -> bool:
	var _name = object.get("name")
	if _name == null:
		return false
	if object != null and object.get_meta_list().has(_name):
		_object_selected = object
		return true
	return false


func _make_visible(visible : bool):
	if visible:
		if _object_selected != null:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _control_menu)
	else:
		remove_control_from_docks(_control_menu)
		_cursor.visible = false
		_marker.visible = false
		_object_selected = null
		
		
func _physics_process(_delta: float) -> void:
	if _mouse_event == EVENT_MOUSE.EVENT_CLICK:
		_raycast_3d.global_transform.origin = _project_ray_origin
		_raycast_3d.global_transform.basis.y = _project_ray_normal
		_raycast_3d.target_position = Vector3(0, 100000, 0)
		_raycast_3d.force_raycast_update()
		if _raycast_3d.is_colliding():
			_cursor.position = _raycast_3d.get_collision_point()
			_position_draw = _raycast_3d.get_collision_point()
			_normal_draw   = _raycast_3d.get_collision_normal()
			_object_draw   = _raycast_3d.get_collider()
			_add_delete_position()
		_mouse_event = EVENT_MOUSE.EVENT_NONE
	elif _mouse_event == EVENT_MOUSE.EVENT_MOVE:
		_raycast_3d.global_transform.origin = _project_ray_origin
		_raycast_3d.global_transform.basis.y = _project_ray_normal
		_raycast_3d.target_position = Vector3(0, 100000, 0)
		_raycast_3d.force_raycast_update()
		if _raycast_3d.is_colliding():
			_cursor.visible = true
			_cursor.position = _raycast_3d.get_collision_point()
		else:
			_cursor.visible = false


func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if _object_selected == null:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_project_ray_origin = viewport_camera.project_ray_origin(event.position)
				_project_ray_normal = viewport_camera.project_ray_normal(event.position)
				_mouse_event = EVENT_MOUSE.EVENT_CLICK
			else:
				_mouse_event = EVENT_MOUSE.EVENT_NONE
			return EditorPlugin.AFTER_GUI_INPUT_STOP
	if event is InputEventMouseMotion and _mouse_event != EVENT_MOUSE.EVENT_CLICK:
		_project_ray_origin = viewport_camera.project_ray_origin(event.position)
		_project_ray_normal = viewport_camera.project_ray_normal(event.position)
		_mouse_event = EVENT_MOUSE.EVENT_MOVE
	return EditorPlugin.AFTER_GUI_INPUT_PASS


func get_selected_nodes(plugin:EditorPlugin)-> void:
	tree.clear()
	var root = plugin.get_editor_interface().get_edited_scene_root()
	await _get_nodes()
	for i in len(nodes2):
		tree.add_item(nodes2[i].name)
		tree.set_item_metadata(i, nodes2[i].get_path())
	tree.hide_on_item_selection = true
	tree.popup_centered()
	nodes2.clear()


func _get_nodes(node = get_editor_interface().get_edited_scene_root(), nodes = []):
	nodes.append(node)
	for childNode in node.get_children():
		_get_nodes(childNode, nodes)
	nodes2 = nodes


func _get_node_by_name(idx: int):
	var _path = tree.get_item_metadata(idx)
	var _name = tree.get_item_text(idx)
	Signals.emit_signal("_pass_node_name", _name, _path)


func _on_set_add_object(value: bool) -> void:
	_add_object = value


func _on_select_btn_toggle(value: bool) -> void:
	_select_object = value
	if !value:
		_marker.visible = false


func _on_set_aabb_center(value: bool) -> void:
	_choose_pos = value
	if value:
		_object_selected._show_aabb()
	elif !value:
		_object_selected._hide_aabb()


func _on_set_mesh_normal(value: bool) -> void:
	if value:
		_object_selected._normal_checked = true
	else:
		_object_selected._normal_checked = false


func _add_delete_position() -> void:
	if _select_object:
		_object_selected._select_mesh(_position_draw, _normal_draw)
	elif _choose_pos:
		_control_menu._aabb_pos_x_readout.value = _position_draw.x
		_control_menu._aabb_pos_y_readout.value = _position_draw.y
		_control_menu._aabb_pos_z_readout.value = _position_draw.z
		var pos = Vector3(_control_menu._aabb_pos_x_readout.value, _control_menu._aabb_pos_y_readout.value, _control_menu._aabb_pos_z_readout.value)
		var size = Vector3(_control_menu._aabb_size_x_readout.value, _control_menu._aabb_size_y_readout.value, _control_menu._aabb_size_z_readout.value)
		_object_selected._create_aabb_outline(pos, size)
	else:
		if _add_object:
			_object_selected._add_mesh(_position_draw, _normal_draw)
		elif not _add_object:
			_object_selected._delete_mesh(_position_draw)


func _generate_multimesh(text : String, rand_rot: Dictionary, rand_scale: Array, count: int, norm: bool, pos: Vector3, size: Vector3, _use_custom: bool):
	_object_selected._validate_gen(text, rand_rot, rand_scale, count, norm, pos, size, _use_custom)


func _on_set_instance(value: int) -> void:
	_control_menu._select_btn.button_pressed = true
	_object_selected._select_instance(value)


func _on_add_btn_toggle(value: bool, button: Button) -> void:
	_on_set_add_object(value)


func _on_scale_change(scaled: float) -> void:
	if not _select_object:
		return
	if _no_signal:
		_object_selected._on_set_scale(scaled, _normal_draw)


func _on_rotate_change(rotated: float) -> void:
	if not _select_object:
		return
	if _no_signal:
		var rot = Vector3(_control_menu._rotate_x_slider.value, _control_menu._rotate_y_slider.value, _control_menu._rotate_z_slider.value)
		_object_selected._on_set_rotate(rot, _normal_draw)
	
	
func _timer_timeout() -> void:
	_no_signal = true
	

func _on_position_change(position: float) -> void:
	if not _select_object:
		return
	if _no_signal:
		var pos = Vector3(_control_menu._pos_x_readout.value, _control_menu._pos_y_readout.value, _control_menu._pos_z_readout.value)
		_object_selected._on_set_position(pos)


func _update_readouts(s, rx, ry, rz, pos):
	_no_signal = false
	_control_menu._scale_slider.value = s
	_control_menu._rotate_x_slider.value = rx
	_control_menu._rotate_y_slider.value = ry
	_control_menu._rotate_z_slider.value = rz
	_control_menu._pos_x_readout.value = pos.x
	_control_menu._pos_y_readout.value = pos.y
	_control_menu._pos_z_readout.value = pos.z
	_no_signal_timer.start(1.0)


func _add_marker(pos: Vector3) -> void:
	_marker.visible = true
	_marker.position = pos
