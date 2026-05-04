class_name SteeringBehaviour
extends Node

@export var weight := 1.0
@export var draw_gizmos := true
@export var enabled := true

var agent: CharacterBody3D

# { SETUP }
func set_agent(a: CharacterBody3D):
	agent = a

# { OVERRIDE }
func calculate() -> Vector3:
	return Vector3.ZERO

func on_draw_gizmos():
	pass

# { DEBUG }
func _process(delta):
	if draw_gizmos and enabled:
		on_draw_gizmos()
