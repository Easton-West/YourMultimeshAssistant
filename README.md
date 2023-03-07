# MultiMeshCreator
A multimesh plugin for Godot 4.x

This tool provides an easy way to place objects onto a mesh, while creating a multimesh, and allowing the transform of each individual instance.


## Features

Strategically place multimesh instances with the click of a mouse

Delete instances from the multimesh as needed

Select an instance and change its transform properties by using the built-in menu

Quickly Generate a multimesh with random rotations within specified limits

Generate a multimesh within a custom aabb vice the entire target mesh

Custom menu to easily add, delete, select and change your multimesh instances

Add a mesh from a node in the scene tree

Create a copy of the multimesh transform into a new MultiMeshInstance3D detached from the plugin


## Usage

Important! You must add an autoload to the project. Use the res://addons/YourMultimeshAssistant/signals.gd script. Verify that the name is Signals. Restart or try to enable the plugin.

Add a YourMultimeshAssitant node to the scene tree

The default mesh will be a BoxMesh and can be changed using the Mesh dropdown or by assigning a MeshInstance3D to the 'Choose Mesh from Tree' box.

The menu for YMMA is located in the rightside dock. Click the tab to access the menu. The menu is only available while you have the 'YourMultimeshAssistant' node selected.

Click 'Add' in the menu and click the mesh you want to add the multimesh to (the target mesh must have a collision shape associated to it).

To delete select 'Delete' and click the instance you want to delete

To change the position, rotation, scale, or normal click 'Select' and click the instance you want to change. Use the functions on the tool bar to change the desired parameter.

The normal can be changed anytime after placing an instance just by selecting the instance then check/uncheck the normal box and change one of the parameters.

Additionally you can use the Generate Multimesh function to quickly create a multimesh. Using the rotation min and max values will rotate each instance randomly between those values. 'Use Vertex Normal' will have the instances follow the mesh normal where they are placed. 'Use Custom AABB' will only place a multimesh with the custom AABB area.

Custom AABB can be set by either typing in the center position or clicking the 'Select with Cursor' button and then clicking on the mesh where you want to place the Multimesh (keep in mind the target mesh must have a collision shape). The size of the AABB can be changed with the 'Size' boxes. The visible AABB (red box) will not change its appearance until you click on the mesh again (future fix coming).

To create a copy of the multimesh transform click the Copy Transform box. This will create a new MultiMeshInstance3D in the scene with the same instances and transform as the plugin. This option may be useful if you do not want to keep the plugin as part of the final product or if the object you are using has multiple meshes associated and you need them all to have the exact same multimesh transform.

Example

Your imported gltf imports as a Node3D. Add it to your scene and then right click and check 'Editable Children'. Expand the node and if there are multiple MeshInstance3Ds you can use one of them as the plugin mesh by assigning it to the 'Choose Mesh from Tree'. Once you are done placing those objects click Copy Transform and a MMI3D node will be added to the scene. You can select another mesh to have the same transform as the first.
	
This may be useful for something like a tree where you want the trunk and leave to be separated meshes. Keep in mind all meshes will use the mesh origin for placing at the target position. This may cause unexpected results if you do not pay attention to the origin before exporting and importing into Godot.



## Limitations

Since Godot doesn't support a way to use Raycast on an object without a collision shape assigned to it (that I'm aware of), the plugin uses a distance to where ever you clicked on the target mesh. If there are multiple instances within the range (0.3) they will all be deleted. Additionally if the instance gets rotated or scaled to where the origin is too far away from the Raycast collision point (> 0.3 set in the code) then it won't be detected. The solution for this is currently to use the 'Instance Select' option in the YMMA Menu. Scroll through until you are on the correct instance and then you can move/rotate/scale.

Using the function which require you to click onto a mesh require the mesh to have a collision shape. If you do not want a collision shape you can add it and then delete it once the multimesh is built. (Generate Multimesh does not require a collision shape).



##Future Updates

Add a delete option based on a multimesh instance that you enter into the 'Select Instance' box

Add a horizontal scroll bar to the transform positions that will allow you to fine tune move the positoning of the selected instance. Currently you have to typ in a position. The scroll bar would allow you to move it +- 5m.

Add dragand drop functionality to moving instances

Add rotation gizmo for rotating an instance

Make the menu colors based on the theme currently set

