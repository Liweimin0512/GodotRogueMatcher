extends Node2D

@onready var gird: Node2D = $Gird
@onready var preview: Node2D = $preview
var s_cell: PackedScene = preload("res://src/entities/cell.tscn")

func _ready() -> void:
	for i in 9:
		for j in 9:
			var cell = s_cell.instantiate()
			cell.position = Vector2(i * 51, j * 51)
			gird.add_child(cell)
	for i in 3:
		var cell = s_cell.instantiate()
		cell.position = Vector2(i * 51, 0)
		preview.add_child(cell)
