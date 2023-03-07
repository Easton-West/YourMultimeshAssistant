@tool
extends Control

@onready var btn_grp : ButtonGroup = load("res://addons/YourMultimeshAssistant/tgl_btn.tres")
@onready var tree = load("res://addons/YourMultimeshAssistant/tree.tscn").instantiate()
#Generate
@onready var _generate_btn := $VBoxContainer/GenerateBtn as Button
@onready var _target_mesh := $VBoxContainer/TargetMeshContainer/TargetMesh as LineEdit
@onready var _choose_mesh := $VBoxContainer/TargetMeshContainer/SelectTargetMesh as LinkButton
@onready var _rand_rot_x_min := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer/MinRotX as SpinBox
@onready var _rand_rot_x_max := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer/MaxRotX as SpinBox
@onready var _rand_rot_y_min := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer2/MinRotY as SpinBox
@onready var _rand_rot_y_max := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer2/MaxRotY as SpinBox
@onready var _rand_rot_z_min := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer3/MinRotZ as SpinBox
@onready var _rand_rot_z_max := $VBoxContainer/RandomRotationContainer/VBoxContainer/HBoxContainer3/MaxRotZ as SpinBox
@onready var _rand_scale_min := $VBoxContainer/RandomScaleContainer/VBoxContainer/HBoxContainer/MinScale as SpinBox
@onready var _rand_scale_max := $VBoxContainer/RandomScaleContainer/VBoxContainer/HBoxContainer/MaxScale as SpinBox
@onready var _instance_count := $VBoxContainer/InstanceCountContainer/InstanceCountReadout as SpinBox
@onready var _use_vertex_normal := $VBoxContainer/UseVertNormContainer/VertexNormal as CheckBox
@onready var _use_custom_aabb := $VBoxContainer/CustomAABBContainer/CustomAABB as CheckBox
#Controls
@onready var _add_btn := $VBoxContainer/Add as Button
@onready var _delete_btn := $VBoxContainer/Delete as Button
@onready var _select_btn := $VBoxContainer/Select as Button
#Instance
@onready var _instance_select := $VBoxContainer/InstanceContainer/HBoxContainer/InstanceSelectReadout as SpinBox
#Transform
@onready var _pos_x_readout := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control/VBoxContainer/PosXReadout as SpinBox
@onready var _pos_y_readout := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control2/VBoxContainer/PosYReadout as SpinBox
@onready var _pos_z_readout := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control3/VBoxContainer/PosZReadout as SpinBox
@onready var _rotate_x_slider := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control4/VBoxContainer/Control/RotXSlider as HSlider
@onready var _rotate_x_readout := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control4/VBoxContainer/RotXReadout as SpinBox
@onready var _rotate_y_slider := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control2/VBoxContainer/Control/RotYSlider as HSlider
@onready var _rotate_y_readout := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control2/VBoxContainer/RotYReadout as SpinBox
@onready var _rotate_z_slider := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control3/VBoxContainer/Control/RotZSlider as HSlider
@onready var _rotate_z_readout := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control3/VBoxContainer/RotZReadout as SpinBox
@onready var _scale_readout := $VBoxContainer/ScaleContainer/HBoxContainer/VBoxContainer/Control/VBoxContainer/ScaleReadout as SpinBox
@onready var _scale_slider := $VBoxContainer/ScaleContainer/HBoxContainer/VBoxContainer/Control/VBoxContainer/Control/ScaleSlider as HSlider
@onready var _reset_rot_x_btn := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control4/ResetXBtn as Button
@onready var _reset_rot_y_btn := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control2/ResetYBtn as Button
@onready var _reset_rot_z_btn := $VBoxContainer/RotationContainer/HBoxContainer/VBoxContainer/Control3/ResetZBtn as Button
@onready var _reset_pos_x_btn := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control/ResetXPos as Button
@onready var _reset_pos_y_btn := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control2/ResetYPos as Button
@onready var _reset_pos_z_btn := $VBoxContainer/PositionContainer/HBoxContainer/VBoxContainer/Control3/ResetZPos as Button
@onready var _reset_s_btn := $VBoxContainer/ScaleContainer/HBoxContainer/VBoxContainer/Control/ResetSBtn as Button
@onready var _mesh_normal := $VBoxContainer/HBoxContainer/NormalContainer/CheckBox as CheckBox
#Custom AABB
@onready var _aabb_center := $VBoxContainer/PositionContainer2/HBoxContainer/Button as Button
@onready var _aabb_pos_x_readout := $VBoxContainer/PositionContainer2/HBoxContainer/VBoxContainer/Control/VBoxContainer/PosXReadout as SpinBox
@onready var _aabb_pos_y_readout := $VBoxContainer/PositionContainer2/HBoxContainer/VBoxContainer/Control2/VBoxContainer/PosYReadout as SpinBox
@onready var _aabb_pos_z_readout := $VBoxContainer/PositionContainer2/HBoxContainer/VBoxContainer/Control3/VBoxContainer/PosZReadout as SpinBox
@onready var _aabb_size_x_readout := $VBoxContainer/SizeContainer/HBoxContainer5/VBoxContainer/Control/VBoxContainer/SizeXReadout as SpinBox
@onready var _aabb_size_y_readout := $VBoxContainer/SizeContainer/HBoxContainer5/VBoxContainer/Control2/VBoxContainer/SizeYReadout as SpinBox
@onready var _aabb_size_z_readout := $VBoxContainer/SizeContainer/HBoxContainer5/VBoxContainer/Control3/VBoxContainer/SizeZReadout as SpinBox


func _ready() -> void:
	_rotate_x_slider.value_changed.connect(_update_rot_x_readout)
	_rotate_y_slider.value_changed.connect(_update_rot_y_readout)
	_rotate_z_slider.value_changed.connect(_update_rot_z_readout)
	_rotate_x_readout.value_changed.connect(_update_rot_x_slide)
	_rotate_y_readout.value_changed.connect(_update_rot_y_slide)
	_rotate_z_readout.value_changed.connect(_update_rot_z_slide)
	_pos_x_readout.value_changed.connect(_check_pos_x_value)
	_pos_y_readout.value_changed.connect(_check_pos_y_value)
	_pos_z_readout.value_changed.connect(_check_pos_z_value)
	_reset_pos_x_btn.pressed.connect(_reset_pos_x)
	_reset_pos_y_btn.pressed.connect(_reset_pos_y)
	_reset_pos_z_btn.pressed.connect(_reset_pos_z)
	_reset_rot_x_btn.pressed.connect(_reset_rot_x)
	_reset_rot_y_btn.pressed.connect(_reset_rot_y)
	_reset_rot_z_btn.pressed.connect(_reset_rot_z)
	_reset_s_btn.pressed.connect(_reset_scale)
	_scale_slider.value_changed.connect(_update_scale_readout)
	_scale_readout.value_changed.connect(_update_scale_slide)
	_generate_btn.pressed.connect(_generate_mm)
	Signals.connect("_set_instance_max", _update_instance_max)
	Signals.connect("_set_instance_value", _update_instance_value)
	Signals.connect("_pass_node_name", _set_target_mesh)
	


func _generate_mm() -> void:
	var text = _target_mesh.placeholder_text
	var count = _instance_count.value
	var rand_rot = {"x" : [_rand_rot_x_min.value, _rand_rot_x_max.value], "y" : [_rand_rot_y_min.value, _rand_rot_y_max.value], "z" : [_rand_rot_z_min.value, _rand_rot_z_max.value]}
	var rand_scale = [_rand_scale_min.value, _rand_scale_max.value]
	var norm = _use_vertex_normal.button_pressed
	var _use_custom = _use_custom_aabb.button_pressed
	var pos = Vector3(_aabb_pos_x_readout.value, _aabb_pos_y_readout.value, _aabb_pos_z_readout.value)
	var _size = Vector3(_aabb_size_x_readout.value, _aabb_size_y_readout.value, _aabb_size_z_readout.value)
	Signals.emit_signal("_set_node_name", text, rand_rot, rand_scale, count, norm, pos, _size, _use_custom)


func _set_target_mesh(_name: String, _path: String) -> void:
	_target_mesh.editable = true
	_target_mesh.text = _name
	_target_mesh.placeholder_text = _path
	_target_mesh.editable = false


func _update_rot_x_readout(value: float) -> void:
	_rotate_x_readout.value = value
	
	
func _update_rot_x_slide(value: float) -> void:
	_rotate_x_slider.value = value
	_reset_rot_x_btn.visible = true if value != 0 else false


func _update_rot_y_readout(value: float) -> void:
	_rotate_y_readout.value = value


func _update_rot_y_slide(value: float) -> void:
	_rotate_y_slider.value = value
	_reset_rot_y_btn.visible = true if value != 0 else false


func _update_rot_z_readout(value: float) -> void:
	_rotate_z_readout.value = value


func _update_rot_z_slide(value: float) -> void:
	_rotate_z_slider.value = value
	_reset_rot_z_btn.visible = true if value != 0 else false


func _update_scale_readout(value: float) -> void:
	_scale_readout.value = value


func _update_scale_slide(value: float) -> void:
	_scale_slider.value = value
	_reset_s_btn.visible = true if value != 1 else false


func _check_pos_x_value(value: float) -> void:
	_reset_pos_x_btn.visible = true if value != 0 else false


func _check_pos_y_value(value: float) -> void:
	_reset_pos_y_btn.visible = true if value != 0 else false


func _check_pos_z_value(value: float) -> void:
	_reset_pos_z_btn.visible = true if value != 0 else false


func _reset_pos_x() -> void:
	_pos_x_readout.value = 0
	
	
func _reset_pos_y() -> void:
	_pos_y_readout.value = 0
	
	
func _reset_pos_z() -> void:
	_pos_z_readout.value = 0


func _reset_rot_x() -> void:
	_rotate_x_slider.value = 0


func _reset_rot_y() -> void:
	_rotate_y_slider.value = 0

	
func _reset_rot_z() -> void:
	_rotate_z_slider.value = 0


func _reset_scale() -> void:
	_scale_slider.value = 1


func _update_instance_value(value: int) -> void:
	_instance_select.value = value
 

func _update_instance_max(value: int) -> void:
	_instance_select.max_value = value - 1
