extends Control
class_name Interface

var interface_name : StringName = ""
var ui_manager: UIManager :
	get:
		return get_parent()

func _opened(data: Dictionary = {}) -> void:
	print("开启了界面：", interface_name)
	pass

func _closed() -> void:
	print("关闭了界面：", interface_name)
	pass
