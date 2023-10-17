extends Node2D

@onready var ui_manager: UIManager = $UIManager
@onready var board: Board = $Board

func _ready() -> void:
	ui_manager.register_interface("game_form", preload("res://src/widgets/form/game_form.tscn"))
	ui_manager.register_interface("popup_game_over", preload("res://src/widgets/popup/w_game_over_popup.tscn"))
	var game_form : GameForm = ui_manager.open_interface("game_form")
	board.game_overed.connect(
		func() -> void:
			get_tree().paused = true
			var popup_game_over : PopupGameOver = ui_manager.open_interface("popup_game_over")
			popup_game_over.quit_pressed.connect(
				func() -> void:
					get_tree().quit()
			)
			popup_game_over.retry_pressed.connect(
				func() -> void:
					board.retry_game()
					popup_game_over.hide()
			)
	)
	board.game_form = game_form
