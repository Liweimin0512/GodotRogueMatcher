extends PopupInterface
class_name PopupNameInput

@onready var te_name: TextEdit = %te_name
@onready var btn_quit: TextureButton = %btn_quit
@onready var btn_confirm: TextureButton = %btn_confirm

signal btn_quit_pressed
signal btn_confirm_pressed(player_name : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn_quit.pressed.connect(_on_btn_quit_pressed)
	btn_confirm.pressed.connect(_on_btn_confirm_pressed)

func _on_btn_quit_pressed() -> void:
	ui_manager.close_current_interface()
	btn_quit_pressed.emit()

func _on_btn_confirm_pressed() -> void:
	if te_name.text.is_empty():
		print_debug("没有输入玩家名，无法提交")
		return
	ui_manager.close_current_interface()
	btn_confirm_pressed.emit(te_name.text)

#func _on_w_name_input_popup_btn_confirm_pressed(player_name: String) -> void:
#	w_name_imput_popup_confirm.emit(player_name)
#	w_game_over_popup.show()
#
#
#func _on_w_name_input_popup_btn_quit_pressed() -> void:
#	w_game_over_popup.show()
