extends Node2D
class_name ChessPiece

@onready var sprite_2d: Sprite2D = $Sprite2D

var animals : Array = [
	preload("res://assets/textures/animals/buffalo.png"), 
	preload("res://assets/textures/animals/chick.png"), 
	preload("res://assets/textures/animals/chicken.png"), 
	preload("res://assets/textures/animals/cow.png"),
	preload("res://assets/textures/animals/crocodile.png"),
]

var piece_type: int = 0 : # -1代表空的网格
	set(value):
		sprite_2d.texture = animals[value]
		piece_type = value

var tween : Tween = null

## 选择动画效果
func selected() -> void:
	print("selected:", self)
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, 'scale', Vector2(0.5, 0.5), 0.2)
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.2)

## 取消选择动画效果
func deselected() -> void:
	print("deselected:", self)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.2)

## 移动动画效果
func move_to(target_cell: Cell) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, 'position', target_cell.position, 0.05)
	await tween.finished
