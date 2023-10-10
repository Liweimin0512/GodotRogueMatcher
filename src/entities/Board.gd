extends Node2D
class_name Board

var s_cell: PackedScene = preload("res://src/entities/cell.tscn")
var s_piece: PackedScene = preload("res://src/entities/chess_piece.tscn")
var rows : int = 9
var cols : int = 9

@export var grid_gap : Vector2 = Vector2(1, 1)
var cell_size: Vector2 = Vector2(50, 50)

## 当前选中的棋子，默认为空
var selected_piece : ChessPiece = null :
	set(value):
		if selected_piece:
			selected_piece.deselected()
		if value:
			value.selected()
		selected_piece = value

## 用来寻路的A星寻路算法的实现
var a_star : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	initialize_board()
	spawn_random_pieces()

## 初始化我们的棋盘
func initialize_board() -> void:
	# 初始化导航区域的大小，这里是9*9网格棋盘
	a_star.region.size = Vector2i(rows, cols)
	# 这里注意禁用对角线移动
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	for i in cols:
		for j in rows:
			var cell : Cell = s_cell.instantiate()
			cell.coordinate = Vector2i(i, j) # cell需要存储一个在棋盘中的坐标信息
			cell.position = Vector2(i * (cell_size.x + grid_gap.x), j * (cell_size.y + grid_gap.y))
			# 将网格点击事件绑定到相应方法
			cell.pressed.connect(_on_cell_pressed)
			# 当棋盘网格的棋子状态发生改变时候，更新AStarGrid2D对象的障碍物信息
			cell.piece_changed.connect(
				func(cell:Cell, piece:ChessPiece) -> void:
					a_star.set_point_solid(cell.coordinate, piece != null)
			)
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
		print("目标位置：", coordinate," 存在棋子，重新随机位置")
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

## 根据坐标集合获取多个棋盘网格
func get_cells(coords: Array) -> Array[Cell]:
	var cells : Array[Cell]
	for c in coords:
		cells.append(get_cell(c))
	return cells

## 判断坐标位置是否存在棋子
func has_piece(coordinate: Vector2i) -> bool:
	var cell = get_cell(coordinate)
	return cell.piece != null

## 网格点击事件处理函数
func _on_cell_pressed(cell: Cell) -> void:
#	print("网格被点击：", cell)
	# 判断点击网格是否有棋子？
	# 有:将其存为选中棋子
	if cell.piece != null:		
		selected_piece = cell.piece
	# 没有: 判断当前是否选中了棋子？
	elif selected_piece != null:
		# 有：执行移动逻辑
		move_selected_piece(cell)
	else:
		# 没有：无操作
		pass

## 移动棋子
func move_selected_piece(target_cell: Cell) -> void:
	var selected_cell: Cell = selected_piece.get_parent()
	# 获取导航路径（坐标点集合）
	var path : Array = a_star.get_point_path(selected_cell.coordinate, target_cell.coordinate)
#	print("path:", path)
	var path_cells: Array = get_cells(path)
	if not path.is_empty():
		# 导航路径不为空，代表有路径
		for c in path_cells:
			# 将路径高亮显示
			c.highlight()
		selected_cell.piece = null
		selected_piece.position = selected_cell.position
		self.add_child(selected_piece)
		for p in path:
			# 使用await关键字，确保每次动画播放完成才进行下一步移动动画
			await selected_piece.move_to(get_cell(p))
		self.remove_child(selected_piece)
		target_cell.piece = selected_piece
		selected_piece.position = Vector2.ZERO
		for c in path_cells:
			# 取消高亮显示
			c.unhighlight()
	selected_piece = null
