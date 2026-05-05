extends CanvasLayer
class_name GameUI

@onready var good_label = $MarginContainer/VBoxContainer/lblGoodFood
@onready var bad_label = $MarginContainer/VBoxContainer/lblBadFood
@onready var interact_label = $MarginContainer/VBoxContainer/lblInteract
@onready var trust_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/TrustBar
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer2/HealthBar

var _trust_fill_style  := StyleBoxFlat.new()
var _health_fill_style := StyleBoxFlat.new()

func _ready():
	add_to_group("ui")
	print("trust_bar node: ", trust_bar)
	print("Children: ", $MarginContainer/VBoxContainer.get_children())
	hide_interact_prompt()
	_setup_bars()

func _setup_bars():
	if trust_bar:
		trust_bar.min_value = 0
		trust_bar.max_value = 100
		trust_bar.value     = 50
		trust_bar.add_theme_stylebox_override("fill", _trust_fill_style)
		_update_trust_color(50)

	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = 100
		health_bar.value     = 100
		health_bar.add_theme_stylebox_override("fill", _health_fill_style)
		_update_health_color(100)

# HUD VISIBILITY
func hide_hud():
	if good_label:     good_label.visible     = false
	if bad_label:      bad_label.visible      = false
	if interact_label: interact_label.visible = false

func show_hud():
	if good_label:  good_label.visible  = true
	if bad_label:   bad_label.visible   = true

# FOOD UI
func update_food(good: int, bad: int):
	if good_label: good_label.text = "Good food: %d" % good
	if bad_label:  bad_label.text  = "Bad food: %d"  % bad

# INTERACT PROMPT
func show_interact_prompt():
	if interact_label: interact_label.visible = true

func hide_interact_prompt():
	if interact_label: interact_label.visible = false

# TRUST BAR
func update_trust(value: float):
	print("update_trust called: ", value, " | trust_bar: ", trust_bar)
	if not trust_bar: return
	trust_bar.value = clamp(value, 0, 100)
	_update_trust_color(trust_bar.value)

func _update_trust_color(value: float):
	var t := value / 100.0
	var color: Color
	if t < 0.5:
		color = Color.RED.lerp(Color.YELLOW, t * 2.0)
	else:
		color = Color.YELLOW.lerp(Color.GREEN, (t - 0.5) * 2.0)
	_trust_fill_style.bg_color = color

# HEALTH BAR
func update_health(value: float):
	if not health_bar: return
	health_bar.value = clamp(value, 0, 100)
	_update_health_color(health_bar.value)

func _update_health_color(value: float):
	var t := value / 100.0
	_health_fill_style.bg_color = Color.RED.lerp(Color.GREEN, t)
