class_name CreditsMenu
extends Control

signal return_pressed

@export var return_button: Button

func _ready() -> void:
	return_button.pressed.connect(on_return_pressed)

func on_return_pressed() -> void:
	return_pressed.emit()
