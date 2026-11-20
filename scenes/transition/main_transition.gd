class_name MainTransition
extends SceneTransition

@export var duration: float = 0.4

func uses_overlay() -> bool:
	return true

func play_out(target: Node) -> void:
	var t := target.get_tree().create_tween()
	t.tween_property(target, "modulate:a", 1.0, duration)
	await t.finished

func play_in(target: Node) -> void:
	var t := target.get_tree().create_tween()
	t.tween_property(target, "modulate:a", 0.0, duration)
	await t.finished
