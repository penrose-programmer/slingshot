extends Node2D

@export var world: Node2D
@export var ui: CanvasLayer
@export var transition: ColorRect

func _ready():
	SceneManager.register(world, ui, transition)
	GameManager.start()
