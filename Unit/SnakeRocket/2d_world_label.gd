extends Control
class_name WorldLabel2D

#这个节点下的control 节点 会按照 相机的zoom调整大小 

func _ready() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		scale = Vector2.ONE / camera.zoom
		print("worldlabel2d 大小为 %s" % scale)
