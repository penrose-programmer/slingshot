class_name LevelSelectMenu
extends Control

signal return_pressed
signal level_button_pressed(index: int)

@export var return_button: Button
@export var level_grid: GridContainer

func _ready() -> void:
	return_button.pressed.connect(on_return_pressed)
	
	for level_button in level_grid.get_children():
		level_button.pressed.connect(on_level_button_pressed.bind(level_button.get_index()))

func on_return_pressed() -> void:
	return_pressed.emit()

func on_level_button_pressed(index: int) -> void:
	level_button_pressed.emit(index)
