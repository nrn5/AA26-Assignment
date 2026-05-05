extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity := 0.009
@export var max_health := 100
@onready var neck := $neck
@onready var camera := $neck/camera
@onready var interaction_area: Area3D = $a3DInteractionArea
@onready var ui: GameUI = get_tree().get_first_node_in_group("ui")
@onready var death_menu := $DeathMenu
@onready var win_menu := $WinMenu

var good_food := 0
var bad_food := 0

var health := 100
var dead := false

var can_look := true
var can_move := true
var paused := false
var mouse_mode := false

var current_target: Interactable = null

signal food_updated(good: int, bad: int)
signal request_pause

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	
	dead = false
	death_menu.visible = false
	win_menu.visible = false
	health = max_health
	if interaction_area:
		interaction_area.area_entered.connect(_on_area_entered)
		interaction_area.area_exited.connect(_on_area_exited)

	if ui:
		ui.hide_interact_prompt()
		ui.update_health(health)

# { INPUT }
func _unhandled_input(event):
	if dead:
		return
	if not can_look:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))

	if Input.is_action_just_pressed("ui_cancel"):
		request_pause.emit()

	if Input.is_action_just_pressed("toggle_mouse"):
		mouse_mode = !mouse_mode

		if mouse_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			if not paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if dead:
		return
	if not can_move:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("interact") and current_target:
		current_target.interact(self)
	move_and_slide()

# { HEALTH SYSTEM }
func take_damage(amount: float):
	if dead:
		return
	health -= amount
	health = clamp(health, 0, max_health)
	if ui:
		ui.update_health(health)
	if health <= 0:
		die()

func die():
	if dead:
		return
	dead = true
	can_move = false
	can_look = false
	velocity = Vector3.ZERO
	
	set_game_ui_enabled(false)
	print("Player died")

	death_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().paused = true

func win():
	dead = true
	can_move = false
	can_look = false
	velocity = Vector3.ZERO
	set_game_ui_enabled(false)

	win_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().paused = true

func set_game_ui_enabled(value: bool):
	if ui:
		ui.visible = value
		
# { FOOD }
func add_food(food: Food):
	if food.is_good:
		good_food += food.value
	else:
		bad_food += food.value
	if ui:
		ui.update_food(good_food, bad_food)

# { INTERACTION }
func _on_area_entered(area):
	if area is Interactable:
		current_target = area
		if ui:
			ui.show_interact_prompt()

func _on_area_exited(area):
	if area == current_target:
		current_target = null
		if ui:
			ui.hide_interact_prompt()
