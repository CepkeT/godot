extends Node2D

signal no_health()
signal damage_recieved()

@onready var health_bar = $Health_Bar
@onready var damage_text = $Damage_Text
@onready var anim_text = $AnimationPlayer

signal health_changed(new_health)

var new_health = 520
var health = new_health:
	set(value):
		health = value
		health_bar.max_value = new_health
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true
		
	

func _ready():
	Signals.connect("player_attack", Callable(self, "_on_damage_received"))
	damage_text.modulate.a = 0
	health_bar.visible = false		
	
func _on_damage_received(player_damage):
	health -= player_damage
	if health_bar.value > health_bar.max_value * 0.7:
		health_bar.tint_progress = Color.DARK_GREEN
	elif health_bar.value > health_bar.max_value * 0.4 :
		health_bar.tint_progress = Color.DARK_GOLDENROD
	else:
		health_bar.tint_progress = Color.DARK_RED
	damage_text.text = str(player_damage)
	anim_text.stop()
	anim_text.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else :
		emit_signal("damage_recieved")
	
