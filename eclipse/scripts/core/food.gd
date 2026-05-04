class_name Food
extends Area3D

@export var is_good := true   # good vs bad food
@export var value := 1

var active := false

func _ready():
	await get_tree().process_frame  # wait 1 frame
	active = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not active:
		return

	if body is Player:
		body.add_food(self)
		queue_free()
