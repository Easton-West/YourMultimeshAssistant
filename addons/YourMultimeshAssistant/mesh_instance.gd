@tool
extends MultiMeshInstance3D

@export_node_path("Node3D") var _choose_mesh_from_tree : NodePath : set = _on_set_node
@export var mesh : Mesh = null : set = _on_set_mesh
@export var _copy_transform : bool = false:
	set(value):
		_create_copy()

var _normal_checked := true
var _selected_mesh : int
var _mesh_cache : Array[Transform3D] = []
var _instance_custom_data : Color
var _vertices : PackedVector3Array
var _normals : PackedVector3Array
var _faces : Array
var _faces_norm : PackedVector3Array
var _custom_aabb : PackedVector3Array
var listOfAllNodesInTree = []
var bounding_box : MeshInstance3D
var _target_mesh : String

@onready var default_mesh := BoxMesh.new()
@onready var _target_mesh_warning = load("res://addons/YourMultimeshAssistant/alerts/target_mesh_warning.tscn").instantiate()
@onready var _confirm_overwrite = load("res://addons/YourMultimeshAssistant/alerts/confirmation_dialog.tscn").instantiate()

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else:
		set_process(false)
	if not get_meta_list().has(name):
		set_meta(name, "1.0.0")
	if multimesh == null:
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_custom_data = true
	if multimesh.mesh == null:
		if mesh == null:
			multimesh.mesh = default_mesh
		else:
			multimesh.mesh = mesh
	var max = multimesh.instance_count
	Signals.emit_signal("_set_instance_max", max)
	get_window().call_deferred(StringName("add_child"), _confirm_overwrite)
	get_window().call_deferred(StringName("add_child"), _target_mesh_warning)


func _process(delta: float) -> void:
	if _mesh_cache.size() > 0:
		_update_multimesh()


func _on_set_node(node: NodePath) -> void:
	
	mesh = get_node(node).get("mesh")
	if Engine.is_editor_hint() and is_inside_tree():
		_update_multimesh()


func _on_set_mesh(value: Mesh) -> void:
	if _choose_mesh_from_tree.is_empty():
		mesh = value
	if Engine.is_editor_hint() and is_inside_tree():
		_update_multimesh()


func _validate_gen(text: String, rand_rot: Dictionary, rand_scale : Array, count: int, norm: bool, p: Vector3, size: Vector3, _use_custom: bool) -> void:
	var node = $"..".get_node_or_null(text)
	if node == null:
		_target_mesh_warning.dialog_text = "\n
		\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020Target mesh does not exist in tree"
		_target_mesh_warning.popup_centered()
		return
	elif not node is MeshInstance3D:
		_target_mesh_warning.dialog_text = "\n
		\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020Target is not a MeshInstance"
		_target_mesh_warning.popup_centered()
		return
	elif node.mesh == null:
		_target_mesh_warning.dialog_text = "\n
		\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020\u0020Target mesh is null"
		_target_mesh_warning.popup_centered()
		return
	if multimesh.instance_count != 0:
		_confirm_overwrite.popup_centered()
		await _confirm_overwrite.get_ok_button().pressed
	_generate_multimesh(node, rand_rot, rand_scale, count, norm, p, size, _use_custom)


func _generate_multimesh(_target_node : Node, rand_rot : Dictionary, rand_scale : Array, count : int, norm: bool, p : Vector3, size : Vector3, _use_custom : bool) -> void:
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.instance_count = count
	if mesh == null:
		multimesh.mesh = default_mesh
	else:
		multimesh.mesh = mesh
	_faces.clear()
	_faces_norm.clear()
	await _create_aabb(_target_node, p, size, _use_custom)
	
	for i in range(count):
		if _faces.size() > 0:
			var _rand_int = randi() % _faces.size()
			var rand_face = _faces[_rand_int]
			var rand_norm = _faces_norm[_rand_int]
			var rand_vec = get_random_point_inside(rand_face)
			var rot_x = randi_range(rand_rot.x[0], rand_rot.x[1])
			var rot_y = randi_range(rand_rot.y[0], rand_rot.y[1])
			var rot_z = randi_range(rand_rot.z[0], rand_rot.z[1])
			var _scale = randf_range(rand_scale[0], rand_scale[1])
			var tx = Transform3D()
		
			if norm:
				_instance_custom_data = Color(rand_norm.x, rand_norm.y, rand_norm.z, _scale)
				var vec_data = Vector3(_instance_custom_data.r, _instance_custom_data.g, _instance_custom_data.b)
				var r_basis = Basis(vec_data.cross(Vector3(0.0, 0.0, 1.0)), vec_data, Vector3(1.0, 0.0, 0.0).cross(vec_data))
				var r = r_basis.get_euler()
				tx = tx.rotated_local(Vector3.UP, r.y)
				tx = tx.rotated_local(Vector3.RIGHT, r.x)
				tx = tx.rotated_local(Vector3.BACK, r.z)
				tx = tx.rotated_local(Vector3.UP, deg_to_rad(rot_y))
				tx = tx.rotated_local(Vector3.RIGHT, deg_to_rad(rot_x))
				tx = tx.rotated_local(Vector3.BACK, deg_to_rad(rot_z))
				tx = tx.scaled(Vector3(_instance_custom_data.a, _instance_custom_data.a, _instance_custom_data.a))
			else:
				_instance_custom_data = Color(0.0, 1.0, 0.0, _scale)
				tx.basis = Basis(Vector3.UP, 0.0)
				tx = tx.rotated_local(Vector3.UP, deg_to_rad(rot_y))
				tx = tx.rotated_local(Vector3.RIGHT, deg_to_rad(rot_x))
				tx = tx.rotated_local(Vector3.BACK, deg_to_rad(rot_z))
			tx.origin = rand_vec
			multimesh.set_instance_transform(i, tx)
			multimesh.set_instance_custom_data(i, _instance_custom_data)
		
	var max = multimesh.instance_count
	Signals.emit_signal("_set_instance_max", max)
	if has_node("bounding_box_123"):
		remove_child(bounding_box)
	
#from Godot source code
func get_random_point_inside(face) -> Vector3:
	var a = randf()
	var b = randf()
	var c : float
	if  a > b:
		c = a
		a = b
		b = c
		
	return face[0] * a + face[1] * (b - a) + face[2] * (1.0 - b)

func _add_mesh(p: Vector3, n: Vector3) -> void:
	var tx = Transform3D()
	if _normal_checked:
		_instance_custom_data = Color(n.x, n.y, n.z, 1.0)
		var vec_data = Vector3(_instance_custom_data.r, _instance_custom_data.g, _instance_custom_data.b)
		var r_basis = Basis(vec_data.cross(Vector3(0.0, 0.0, 1.0)), vec_data, Vector3(1.0, 0.0, 0.0).cross(vec_data))
		var r = r_basis.get_euler()
		tx = tx.rotated_local(Vector3.UP, r.y)
		tx = tx.rotated_local(Vector3.RIGHT, r.x)
		tx = tx.rotated_local(Vector3.BACK, r.z)
		tx = tx.scaled(Vector3(_instance_custom_data.a, _instance_custom_data.a, _instance_custom_data.a))
	else:
		_instance_custom_data = Color(0.0, 1.0, 0.0, 1.0)
		tx.basis = Basis(Vector3.UP, 0.0)
	tx.origin = p
	_mesh_cache.append(tx)


func _delete_mesh(p: Vector3) -> void:
	if multimesh.instance_count == 0:
		return
	var new_multimesh := MultiMesh.new()
	var array : Array[Transform3D] = []
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	new_multimesh.use_custom_data = true
	if mesh != null:
		new_multimesh.mesh = mesh
	else:
		new_multimesh.mesh = default_mesh
	for i in range(multimesh.instance_count):
		var vec := multimesh.get_instance_transform(i)
		if vec.origin.distance_to(p) > 0.5:
			array.append(vec)
	new_multimesh.instance_count = array.size()
	for i in range(array.size()):
		new_multimesh.set_instance_transform(i, array[i])
		new_multimesh.set_instance_custom_data(i, multimesh.get_instance_custom_data(i))
	multimesh = new_multimesh
	var max = multimesh.instance_count
	Signals.emit_signal("_set_instance_max", max)


func _select_instance(value: int) -> void:
	var tx = multimesh.get_instance_transform(value)
	_selected_mesh = value
	_set_scale_rotation_position(tx)
	Signals.emit_signal("_set_marker", tx.origin)


func _select_mesh(p: Vector3, n: Vector3) -> void:
	if multimesh.instance_count == 0:
		return
	for i in multimesh.instance_count:
		var tx := multimesh.get_instance_transform(i)
		if tx.origin.distance_to(p) < 0.3:
			_selected_mesh = i
			_set_scale_rotation_position(tx)
			Signals.emit_signal("_set_marker", tx.origin)
			Signals.emit_signal("_set_instance_value", i)


func _update_multimesh() -> void:
	if multimesh == null:
		return
	var new_multimesh := MultiMesh.new()
	var prior_count := multimesh.instance_count
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	new_multimesh.use_custom_data = true
	if !_choose_mesh_from_tree.is_empty():
		new_multimesh.mesh = get_node(_choose_mesh_from_tree).get("mesh")
	elif mesh != null:
		new_multimesh.mesh = mesh
	else:
		new_multimesh.mesh = default_mesh
	new_multimesh.instance_count = prior_count + _mesh_cache.size()
	for i in range(multimesh.instance_count):
		new_multimesh.set_instance_transform(i, multimesh.get_instance_transform(i))
		new_multimesh.set_instance_custom_data(i, multimesh.get_instance_custom_data(i))
	for i in range(_mesh_cache.size()):
		new_multimesh.set_instance_transform(i + prior_count, _mesh_cache[i])
		new_multimesh.set_instance_custom_data(i + prior_count, _instance_custom_data)
	multimesh = new_multimesh
	_mesh_cache.clear()
	var max = multimesh.instance_count
	Signals.emit_signal("_set_instance_max", max)
	

func _on_set_position(p: Vector3) -> void:
	var i = multimesh.get_instance_transform(_selected_mesh)
	var _basis = i.basis
	var tx = Transform3D(_basis, p)
	multimesh.set_instance_transform(_selected_mesh, tx)


func _on_set_scale(scaled: float, n: Vector3) -> void:
	var tx = Transform3D()
	var _custom_data = multimesh.get_instance_custom_data(_selected_mesh)
	var instance_tx = multimesh.get_instance_transform(_selected_mesh)
	var r_basis : Basis
	if _normal_checked:
		r_basis = Basis(n.cross(Vector3(0.0, 0.0, 1.0)), n, Vector3(1.0, 0.0, 0.0).cross(n))
	else:
		r_basis = Basis(Vector3.UP, 0.0)
	var r = r_basis.get_euler()
	tx = tx.rotated_local(Vector3.UP, r.y)
	tx = tx.rotated_local(Vector3.RIGHT, r.x)
	tx = tx.rotated_local(Vector3.BACK, r.z)
	tx = tx.rotated_local(Vector3.UP, deg_to_rad(_custom_data.g))
	tx = tx.rotated_local(Vector3.RIGHT, deg_to_rad(_custom_data.r))
	tx = tx.rotated_local(Vector3.BACK, deg_to_rad(_custom_data.b))
	tx = tx.orthonormalized()
	tx = tx.scaled(Vector3(scaled, scaled, scaled))
	tx.origin = instance_tx.origin
	multimesh.set_instance_custom_data(_selected_mesh, Color(_custom_data.r, _custom_data.g, _custom_data.b, scaled))
	multimesh.set_instance_transform(_selected_mesh, tx)

	
func _on_set_rotate(rotated: Vector3, n: Vector3) -> void:
	var tx = Transform3D()
	var _custom_data = multimesh.get_instance_custom_data(_selected_mesh)
	var instance_tx = multimesh.get_instance_transform(_selected_mesh)
	var r_basis : Basis
	if _normal_checked:
		r_basis = Basis(n.cross(Vector3(0.0, 0.0, 1.0)), n, Vector3(1.0, 0.0, 0.0).cross(n))
	else:
		r_basis = Basis(Vector3.UP, 0.0)
	var r = r_basis.get_euler()
	tx = tx.rotated_local(Vector3.UP, r.y)
	tx = tx.rotated_local(Vector3.RIGHT, r.x)
	tx = tx.rotated_local(Vector3.BACK, r.z)
	tx = tx.rotated_local(Vector3.UP, deg_to_rad(rotated.y))
	tx = tx.rotated_local(Vector3.RIGHT, deg_to_rad(rotated.x))
	tx = tx.rotated_local(Vector3.BACK, deg_to_rad(rotated.z))
	tx.basis = tx.basis.orthonormalized()
	tx = tx.scaled(Vector3(_custom_data.a, _custom_data.a, _custom_data.a))
	tx.origin = instance_tx.origin
	multimesh.set_instance_custom_data(_selected_mesh, Color(rotated.x, rotated.y, rotated.z, _custom_data.a))
	multimesh.set_instance_transform(_selected_mesh, tx)


func _set_scale_rotation_position(tx: Transform3D) -> void:
	var _custom_data = multimesh.get_instance_custom_data(_selected_mesh)
	var deg_z = rad_to_deg(_custom_data.g)
	var deg_x = rad_to_deg(_custom_data.r)
	var deg_y = rad_to_deg(_custom_data.b)
	var _scale = _custom_data.a
	var _pos = tx.origin
	Signals.emit_signal("_update_boxes", _scale, _custom_data.r, _custom_data.g, _custom_data.b, _pos)


func _create_copy() -> void:
	if !Engine.is_editor_hint():
		return
	var new_multimesh = MultiMesh.new()
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#new_multimesh.use_custom_data
	new_multimesh.instance_count = multimesh.instance_count
	new_multimesh.transform_array = multimesh.transform_array
	new_multimesh.mesh = BoxMesh.new()
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = new_multimesh
	var main_root = $".."
	main_root.add_child(mmi)
	mmi.name = "YourMultimeshAssistantInstance"
	mmi.owner = main_root
	var script = load("res://addons/YourMultimeshAssistant/multimesh_instance.gd")
	mmi.set_script(script)


func _create_aabb(_target_node: Node, p: Vector3, size: Vector3, use_custom : bool) -> void:
	var arr_mesh = ArrayMesh.new()
	var mdt = MeshDataTool.new()
	if _target_node.mesh is PrimitiveMesh:
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _target_node.mesh.get_mesh_arrays())
		mdt.create_from_surface(arr_mesh, 0)
	else:
		mdt.create_from_surface(_target_node.mesh, 0)
		
	var p1 = Vector3(p.x - size.x/2, p.y - size.y/2, p.z - size.z/2)
	var p3 = Vector3(p.x + size.x/2, p.y + size.y/2, p.z + size.z/2)
	
	if use_custom:
		for i in mdt.get_face_count():
			var a = mdt.get_face_vertex(i, 0)
			var b = mdt.get_face_vertex(i, 1)
			var c = mdt.get_face_vertex(i, 2)
			var av = mdt.get_vertex(a) + _target_node.global_position
			var bv = mdt.get_vertex(b) + _target_node.global_position
			var cv = mdt.get_vertex(c) + _target_node.global_position
			var arr = [av, bv, cv]
			var check = arr.all(func(x) : return (x.x > p1.x and x.x < p3.x) and (x.y > p1.y and x.y < p3.y) and (x.z > p1.z and x.z < p3.z))
			if check:
				_faces.push_back(arr)
				_faces_norm.push_back(mdt.get_face_normal(i))
	else:
		for i in mdt.get_face_count():
			var a = mdt.get_face_vertex(i, 0)
			var b = mdt.get_face_vertex(i, 1)
			var c = mdt.get_face_vertex(i, 2)
			var av = mdt.get_vertex(a) + _target_node.global_position
			var bv = mdt.get_vertex(b) + _target_node.global_position
			var cv = mdt.get_vertex(c) + _target_node.global_position
			var arr = [av, bv, cv]
			_faces.push_back(arr)
			_faces_norm.push_back(mdt.get_face_normal(i))


func _create_aabb_outline(pos: Vector3, size: Vector3) -> void:
	var node = get_node("bounding_box_123") if get_child_count(true) > 0 else null
	if node != null:
		remove_child(node)
	var mesh = BoxMesh.new()
	bounding_box = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.0, 0.0, 0.4)
	#mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = true
	bounding_box.mesh = mesh
	bounding_box.mesh.surface_set_material(0, mat)
	bounding_box.mesh.size = size
	bounding_box.position = pos
	bounding_box.name = "bounding_box_123"
	add_child(bounding_box)

func _hide_aabb() -> void:
	if has_node("bounding_box_123"):
		bounding_box.visible = false
		
func _show_aabb() -> void:
	if has_node("bounding_box_123"):
		bounding_box.visible = true
