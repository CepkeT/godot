extends Node2D

signal no_health()
signal damage_recieved()

@onready var health_bar = $Health_Bar
@onready var damage_text = $Damage_Text
@onready var anim_text = $AnimationPlayer

signal health_changed(max_health)

@export var max_health = 520
var health = 100:
	set(value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true
		
	

func _ready():
	damage_text.modulate.a = 0
	health_bar.value = max_health
	health = max_health
	health_bar.visible = false		
	

func _on_hurt_box_area_entered(_area):
	await get_tree().create_timer(0.02).timeout
	health -= Global.player_damage
	if health_bar.value > health_bar.max_value * 0.7:
		health_bar.tint_progress = Color.DARK_GREEN
	elif health_bar.value > health_bar.max_value * 0.4 :
		health_bar.tint_progress = Color.DARK_GOLDENROD
	else:
		health_bar.tint_progress = Color.DARK_RED
	damage_text.text = str (Global.player_damage)
	anim_text.stop()
	anim_text.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else :
		emit_signal("damage_recieved")
