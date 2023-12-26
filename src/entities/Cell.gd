extends Node2D
class_name Cell


## 网格坐标（在棋盘当中的坐标）
var coordinate: Vector2i = Vector2i.ZERO
## 默认背景色
@export var default_bg_color : Color = Color.html("#313131")
## 高亮背景色
@export var highlight_bg_color : Color = Color.DARK_GRAY

## 当前网格包含的棋子
var piece: ChessPiece = null: 
	set(value):
		if piece != null:
			self.remove_child(piece)
		if value != null:
			self.add_child(value)
		piece = value
		piece_changed.emit(self, piece)

signal pressed(cell: Cell)
signal piece_changed(cell: Cell, piece: ChessPiece)

func _ready() -> void:
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
#			print("_on_area_2d_input_event") 
			pressed.emit(self)

## 高亮
func highlight() -> void:
	$ColorRect.color = highlight_bg_color

## 取消高亮
func unhighlight() -> void:
	$ColorRect.color = default_bg_color
 
func _to_string() -> String:
	return name + ":" + str(self.coordinate)
