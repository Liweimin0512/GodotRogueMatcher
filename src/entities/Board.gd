extends Node2D
class_name Board

var s_cell: PackedScene = preload("res://src/entities/cell.tscn")
var s_piece: PackedScene = preload("res://src/entities/chess_piece.tscn")
var rows : int = 9
var cols : int = 9
var cell_size: Vector2 = Vector2(50, 50)
@export var grid_gap : Vector2 = Vector2(1, 1)

func _ready() -> void:
	initialize_board()
	spawn_random_pieces()


## 初始化我们的棋盘
func initialize_board() -> void:
	for i in cols:
		for j in rows:
			var cell = s_cell.instantiate()
			cell.position = Vector2(i * (cell_size.x + grid_gap.x), \
				j * (cell_size.y + grid_gap.y))
			self.add_child(cell)

## 创建随机棋子
func spawn_random_pieces() -> void:
	for i in range(3):
		# 随机网格，判断这个网格为空则生成，否则重新查找网格
		spawn_piece()
	
## 在指定位置生成一个随机的棋子
func spawn_piece() -> void:
	var coordinate : Vector2i = Vector2i(randi_range(0, rows-1), randi_range(0, cols-1))
	if has_piece(coordinate):
		return spawn_piece()
	# 找到对应坐标位置的网格Grid
	var cell : Cell = get_cell(coordinate)
	var piece: ChessPiece = s_piece.instantiate()
	cell.piece = piece
	piece.piece_type = randi_range(0, 4)
	print("生成棋子：", piece.piece_type," 在位置：",coordinate)

## 根据坐标获取网格
func get_cell(coordinate: Vector2i) -> Cell:
	var grid_index : int = coordinate.x * cols + coordinate.y
	var cell : Cell = self.get_child(grid_index)
	return cell

## 判断坐标位置是否存在棋子
func has_piece(coordinate: Vector2i) -> bool:
	var cell = get_cell(coordinate)
	return cell.piece != null
