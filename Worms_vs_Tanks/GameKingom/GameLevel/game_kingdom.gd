extends Node2D

@onready var light_animation = $Light/LightAnimation
@onready var pointlight1 = $Light/RightLump
@onready var pointlight2 = $Light/LeftLump
@onready var day_text = $Statuses/Day

@onready var player = $Player/Player

var mushroom_preload = preload("res://GameKingom/Units/Mobs/Mushroom/mushroom.tscn")

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}
	
var state = MORNING
var day_count: int = 0

func _ready():
	day_count = 0
	morning_state()

func _on_light_change_timeout():
	if state < 3:
		state += 1
	else:
		state = MORNING
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	
func morning_state():
	day_count += 1
	day_text.text = "Day " + str(day_count)
	light_animation.play("sunrise")

func evening_state():
	light_animation.play("sunset")

func _on_spawner_timeout():
	mushrooom_spawn()

func mushrooom_spawn():
	var mushroom = mushroom_preload.instantiate()
	mushroom.position = Vector2(randi_range(-800, -200),525)
	$Mobs.add_child(mushroom)
