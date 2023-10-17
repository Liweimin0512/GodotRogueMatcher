extends CanvasLayer
class_name UIManager

@export var interfaces := {}
var current_interface : Interface:
	get:
		return self.get_child(-1)

func register_interface(ui_name: StringName, interface: PackedScene) -> void:
#	if not "interface_name" in inerface: return
#	interface.interface_name = ui_name
	interfaces[ui_name] = interface

func get_interface(ui_name: StringName) -> Control:
	for interface in get_children():
		if interface.interface_name == ui_name:
			return interface
	return null

func open_interface(ui_name: StringName, msg: Dictionary = {}) -> Control:
	if not interfaces.has(ui_name): return null
	if current_interface:
		current_interface.hide()
	var interface = get_interface(ui_name)
	if interface:
		self.move_child(interface, -1)
	else:
		interface = interfaces[ui_name].instantiate()
		interface.interface_name = ui_name
		self.add_child(interface)
	interface._opened(msg)
	interface.show()
	return interface

func close_current_interface() -> void:
	var interface = current_interface
	self.remove_child(interface)
	interface._closed()
	interface.queue_free()
#	current_interface._opened()
	if current_interface:
		current_interface.show()
