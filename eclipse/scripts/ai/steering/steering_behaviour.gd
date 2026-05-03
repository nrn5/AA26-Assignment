class_name SteeringBehaviour
extends Node

# global weight, controls how strong this behaviour is in final mix
@export var weight := 1.0
@export var show_gizmos := true

var agent: CharacterBody3D

func calculate() -> Vector3:
	return Vector3.ZERO

func on_draw_gizmos():
	pass
