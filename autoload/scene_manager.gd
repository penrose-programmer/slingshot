extends Node

const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const LEVEL_SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select_menu.tscn")
const CREDITS_SCENE: PackedScene = preload("res://scenes/ui/credits_menu.tscn")

const MAIN_TRANSITION: SceneTransition = preload("res://scenes/transition/main_transition.tres")
const GAME_TRANSITION: SceneTransition = preload("res://scenes/transition/game_transition.tres")
const MENU_TRANSITION: SceneTransition = preload("res://scenes/transition/menu_transition.tres")

var world_layer: Node2D
var ui_layer: CanvasLayer
var transition_rect: ColorRect

const LEVELS_DIR: String = "res://scenes/levels/"

var levels: Array[String] = []
var current_index: int = -1

var current_scene: Node
var busy: bool = false

func _ready():
	GameManager.level_complete.connect(next_level)
	GameManager.player_death.connect(restart_level)
	refresh_levels()

func register(p_world: Node2D, p_ui: CanvasLayer, p_transition: ColorRect) -> void:
	world_layer = p_world
	ui_layer = p_ui
	transition_rect = p_transition

func clear_scene(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func target_for(transition: SceneTransition, scene: Node) -> Node:
	return transition_rect if transition.uses_overlay() else scene

func hide_scene(container: Node, transition: SceneTransition) -> void:
	if busy:
		return
	busy = true
	
	get_viewport().set_disable_input(true)
	
	if current_scene:
		await transition.play_out(target_for(transition, current_scene))
	
	clear_scene(container)
	
	busy = false

func show_scene(container: Node, scene: PackedScene, transition: SceneTransition) -> Node:
	current_scene = scene.instantiate()
	container.add_child(current_scene)
	
	await transition.play_in(target_for(transition, current_scene))
	
	get_viewport().set_disable_input(false)
	
	busy = false
	return current_scene

func change_scene(container: Node, scene: PackedScene, transition: SceneTransition, wait_time: float) -> Node:
	if busy:
		return
	busy = true
	
	get_viewport().set_disable_input(true)
	
	if current_scene:
		await transition.play_out(target_for(transition, current_scene))
	
	await get_tree().create_timer(wait_time).timeout
	
	clear_scene(container)
	current_scene = scene.instantiate()
	container.add_child(current_scene)
	
	await transition.play_in(target_for(transition, current_scene))
	
	get_viewport().set_disable_input(false)
	
	busy = false
	return current_scene

func start_main_menu() -> void:
	var menu: MainMenu = await change_scene(ui_layer, MENU_SCENE, MAIN_TRANSITION, 0.0)
	menu.play_pressed.connect(show_level_select)
	menu.credits_pressed.connect(show_credits_menu)

func show_main_menu() -> void:
	var menu: MainMenu = await change_scene(ui_layer, MENU_SCENE, MENU_TRANSITION, 0.0)
	menu.play_pressed.connect(show_level_select)
	menu.credits_pressed.connect(show_credits_menu)

func show_level_select() -> void:
	var level_select_menu: LevelSelectMenu = await change_scene(ui_layer, LEVEL_SELECT_SCENE, MENU_TRANSITION, 0.0)
	level_select_menu.level_button_pressed.connect(hide_level_select)
	level_select_menu.return_pressed.connect(show_main_menu)

func hide_level_select(index: int) -> void:
	await hide_scene(ui_layer, MAIN_TRANSITION)
	start_game(index)

func show_credits_menu() -> void:
	var credits: CreditsMenu = await change_scene(ui_layer, CREDITS_SCENE, MENU_TRANSITION, 0.0)
	credits.return_pressed.connect(show_main_menu)

func refresh_levels() -> void:
	levels.clear()
	var dir := DirAccess.open(LEVELS_DIR)

	for file in dir.get_files():
		file = file.trim_suffix(".remap")
		if file.get_extension() == "tscn":
			levels.append(LEVELS_DIR.path_join(file))
	
	levels.sort_custom(func(a: String, b: String) -> bool:
		return a.naturalnocasecmp_to(b) < 0)

func start_game(index: int) -> void:
	if index > levels.size() - 1:
		return
	await show_scene(world_layer, load(levels[index]), MAIN_TRANSITION)
	current_index = index

func load_level(index: int) -> void:
	if index > levels.size() - 1:
		return
	await change_scene(world_layer, load(levels[index]), GAME_TRANSITION, 0.2)
	current_index = index

func restart_level() -> void:
	load_level(current_index)

func next_level() -> void:
	load_level(current_index + 1)
