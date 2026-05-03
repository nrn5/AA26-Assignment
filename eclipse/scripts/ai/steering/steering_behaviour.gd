class_name SteeringBehaviour
extends Node

@export var weight := 1.0
@export var draw_gizmos := true
@export var enabled := true : set = set_enabled, get = is_enabled

# reference to whatever uses this behaviour
var agent

func set_enabled(e):
	enabled = e
	set_process(enabled)

func is_enabled():
	return enabled

func calculate() -> Vector3:
	return Vector3.ZERO

func on_draw_gizmos():
	pass

func _process(delta):
	if draw_gizmos and enabled:
		on_draw_gizmos()
