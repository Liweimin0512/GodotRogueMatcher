extends Node2D
class_name ChessPiece

@onready var sprite_2d: Sprite2D = $Sprite2D

var animals : Array = [
	preload("res://assets/texture/animals/bear.png"), 
	preload("res://assets/texture/animals/buffalo.png"), 
	preload("res://assets/texture/animals/chick.png"), 
	preload("res://assets/texture/animals/chicken.png"), 
	preload("res://assets/texture/animals/cow.png")
]

var piece_type: int = 0 : # -1代表空的网格
	set(value):
		sprite_2d.texture = animals[value]
		piece_type = value
