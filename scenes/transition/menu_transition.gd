class_name MenuTransition
extends SceneTransition

@export var duration: float = 0.2

func play_out(target: Node) -> void:
	var t := target.get_tree().create_tween()
	target.modulate.a = 1.0
	t.tween_property(target, "modulate:a", 0.0, duration)
	await t.finished

func play_in(target: Node) -> void:
	var t := target.get_tree().create_tween()
	target.modulate.a = 0.0
	t.tween_property(target, "modulate:a", 1.0, duration)
	await t.finished
