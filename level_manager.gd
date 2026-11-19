extends Node

signal level_loaded(index: int, path: String)
signal all_levels_completed

const LEVELS_DIR: String = "res://levels/"

var levels: Array[String] = []
var current_index: int = -1

func _ready() -> void:
	refresh_levels()

func refresh_levels() -> void:
	levels.clear()
	var dir := DirAccess.open(LEVELS_DIR)

	for file in dir.get_files():
		file = file.trim_suffix(".remap")
		if file.get_extension() == "tscn":
			levels.append(LEVELS_DIR.path_join(file))
	
	levels.sort_custom(func(a: String, b: String) -> bool:
		return a.naturalnocasecmp_to(b) < 0)

func load_level(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	current_index = index
	for child in get_children():
		child.queue_free()
	add_child(load(levels[index]).instantiate())
	level_loaded.emit(index, levels[index])

func load_first_level() -> void:
	load_level(0)

func reload_level() -> void:
	load_level(current_index)

func previous_level() -> void:
	load_level(current_index - 1)

func next_level() -> void:
	if has_next_level():
		load_level(current_index + 1)
	else:
		all_levels_completed.emit()

func has_next_level() -> bool:
	return current_index + 1 < levels.size()

func load_level_by_name(level_name: String) -> void:
	var path := LEVELS_DIR.path_join(level_name + ".tscn")
	var idx := levels.find(path)
	load_level(idx)

func get_level_count() -> int:
	return levels.size()
