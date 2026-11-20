class_name MainMenu
extends Control

signal play_pressed
signal credits_pressed

@export var play_button: Button
@export var credits_button: Button

func _ready() -> void:
	play_button.pressed.connect(on_play_pressed)
	credits_button.pressed.connect(on_credits_pressed)

func on_play_pressed() -> void:
	play_pressed.emit()

func on_credits_pressed() -> void:
	credits_pressed.emit()
