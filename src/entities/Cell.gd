extends Node2D
class_name Cell

## 网格索引
var index :int = 0 
## 当前网格包含的棋子
var piece: ChessPiece = null: 
	set(value):
		if piece != null:
			self.remove_child(piece)
		if value != null:
			self.add_child(value)
		piece = value

func _ready() -> void:
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			print("_on_area_2d_input_event") 
