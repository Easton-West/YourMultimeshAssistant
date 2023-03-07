@tool
extends MultiMeshInstance3D

@export_node_path("Node3D") var _node_mesh : NodePath : set = _on_set_node


func _on_set_node(node: NodePath) -> void:
	multimesh.mesh = get_node(node).get("mesh")
