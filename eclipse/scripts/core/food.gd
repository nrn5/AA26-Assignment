class_name Food
extends Area3D

@export var is_good := true   # good vs bad food
@export var value := 1
@export var spin_speed := 1.5
@export var tilt_angle := 20.0

var active := false

func _ready():
	await get_tree().process_frame  # wait 1 frame
	active = true
	rotation_degrees.x = tilt_angle
	body_entered.connect(_on_body_entered)

func _process(delta):
	rotate_y(spin_speed * delta)

func _on_body_entered(body):
	if not active:
		return

	if body is Player:
		body.add_food(self)
		queue_free()
