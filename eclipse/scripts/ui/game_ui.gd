extends CanvasLayer
class_name GameUI

@onready var good_label = $MarginContainer/VBoxContainer/lblGoodFood
@onready var bad_label = $MarginContainer/VBoxContainer/lblBadFood

func update_food(good: int, bad: int):
	good_label.text = "Good food: %d" % good
	bad_label.text = "Bad food: %d" % bad
