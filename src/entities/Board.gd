extends Node2D
class_name Board

@onready var label: Label = $"../Control/MarginContainer/Label"

var s_cell: PackedScene = preload("res://src/entities/cell.tscn")
var s_piece: PackedScene = preload("res://src/entities/chess_piece.tscn")
@export var rows : int = 9
@export var cols : int = 9

@export var grid_gap : Vector2 = Vector2(1, 1)
var cell_size: Vector2 = Vector2(64, 64)

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

var can_selected: bool = true
var score : int = 0 :
	set(value):
		label.text = "分数：" + str(value)
		print("分数改变，改变前：", score,"改变后：", value)
		game_form.update_score_display(value)
		score = value

var piece_count: int = 0
var game_form : GameForm

signal game_overed

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

## 重试
func retry_game() -> void:
	for cell in self.get_children():
		cell.piece = null
	score = 0
	piece_count = 0
	spawn_random_pieces()
	get_tree().paused = false

func game_over() -> void:
	game_overed.emit()

## 创建随机棋子
func spawn_random_pieces() -> void:
	if rows * cols - piece_count <= 3:
		game_over()
		return
	for i in range(3):
		# 随机网格，判断这个网格为空则生成，否则重新查找网格
		spawn_piece()
		piece_count += 1
	
## 在指定位置生成一个随机的棋子
func spawn_piece() -> void:
	var coordinate : Vector2i = Vector2i(randi_range(0, rows-1), randi_range(0, cols-1))
	if has_piece(coordinate):
#		print("目标位置：", coordinate," 存在棋子，重新随机位置")
		return spawn_piece()
	# 找到对应坐标位置的网格Grid
	var cell : Cell = get_cell(coordinate)
	var piece: ChessPiece = s_piece.instantiate()
	cell.piece = piece
	piece.piece_type = randi_range(0, 4)
#	print("生成棋子：", piece.piece_type," 在位置：", coordinate)

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
	if not can_selected:
		return
	# 判断点击网格是否有棋子？
	# 有:将其存为选中棋子
	if cell.piece != null:		
		selected_piece = cell.piece
	# 没有: 判断当前是否选中了棋子？
	elif selected_piece != null:
		# 有：执行移动逻辑
		var can_move = await move_selected_piece(cell)
		if can_move:
			check_for_elimination(cell)
			spawn_random_pieces()
	else:
		# 没有：无操作
		pass

## 移动棋子
func move_selected_piece(target_cell: Cell) -> bool:
	can_selected = false
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
	can_selected = true
	return not path.is_empty()

# 检查是否有可以消除的棋子
func check_for_elimination(target_cell: Cell):
	var to_eli := []
	var to_elimination = check_direction(target_cell, 1, 0)
	if to_elimination.size() >= 5:
#		eliminate_and_score(to_elimination)
		to_eli += to_elimination
	to_elimination = check_direction(target_cell, 0, 1)
	if to_elimination.size() >= 5:
#		eliminate_and_score(to_elimination)
		to_eli += to_elimination
	to_elimination = check_direction(target_cell, 1, 1)
	if to_elimination.size() >= 5:
#		eliminate_and_score(to_elimination)
		to_eli += to_elimination
	to_elimination = check_direction(target_cell, 1, -1)
	if to_elimination.size() >= 5:
		to_eli += to_elimination
	eliminate_and_score(to_eli)

# 检查从给定位置开始的特定方向是否有五个或更多相同的棋子
func check_direction(start_cell: Cell, delta_row: int, delta_col: int) -> Array:
	if start_cell.piece == null: return [] # 如果起始位置为空，则直接返回空数组
	var to_eliminate = [start_cell]  # 待消除的棋子数组

	for direction in [-1, 1]:
		var local_step = 1  # 用于跟踪在每个方向上走了多少步
		var can_eliminate = true
		while can_eliminate:
			var new_coord = Vector2i(
				start_cell.coordinate.x + local_step * direction * delta_row,
				start_cell.coordinate.y + local_step * direction * delta_col
			)
			# 检查边界条件
			if new_coord.x < 0 or new_coord.x >= self.rows or new_coord.y < 0 or new_coord.y >= self.cols:
				break
			var new_cell : Cell = get_cell(new_coord)
			if new_cell.piece == null:
				break
			if new_cell.piece.piece_type == start_cell.piece.piece_type:
				if not to_eliminate.has(new_cell):
					to_eliminate.append(new_cell)
				local_step += 1 # 更新步数
			else:
				can_eliminate = false
	print("当前可消除棋子：", to_eliminate)
	return to_eliminate

## 消除并得分
func eliminate_and_score(to_eliminate: Array) -> void:
	var score_base: int = 10 if to_eliminate.size() <= 5 else (10 + 2 * (to_eliminate.size() - 5))
	score += score_base * to_eliminate.size()
	for cell in to_eliminate:
		cell.piece = null
	piece_count -= to_eliminate.size()
