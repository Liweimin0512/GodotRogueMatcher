extends PopupInterface
class_name PopupGameOver

@onready var btn_quit: TextureButton = %btn_quit
@onready var btn_retry: TextureButton = %btn_retry

signal quit_pressed
signal retry_pressed

func _ready() -> void:
	btn_quit.pressed.connect(_on_btn_quit_pressed)
	btn_retry.pressed.connect(_on_btn_retry_pressed)

func _on_btn_quit_pressed() -> void:
#	ui_manager.close_current_interface()
	quit_pressed.emit()

func _on_btn_retry_pressed() -> void:
	ui_manager.close_current_interface()
	retry_pressed.emit()
