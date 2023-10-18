extends Node2D

@onready var ui_manager: UIManager = $UIManager
@onready var board: Board = $Board

func _ready() -> void:
	ui_manager.subscribe("popup_game_over_quit_game", 
		func() -> void:
			get_tree().quit()
	)
	ui_manager.subscribe("popup_game_over_retry_game",
		func() -> void:
			board.retry_game()
			ui_manager.close_current_interface()
	)
	var game_form : GameForm = ui_manager.open_interface("game_form")
	board.game_overed.connect(
		func() -> void:
			get_tree().paused = true
			var popup_game_over : PopupGameOver = ui_manager.open_interface("popup_game_over")
	)
	board.game_form = game_form
