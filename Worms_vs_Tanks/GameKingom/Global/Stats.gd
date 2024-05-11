extends CanvasLayer

signal no_stamina()
signal mo_stamina()

@onready var health_bar = $HPBar
@onready var stamina_bar = $Stamina
@onready var health_text = $"../HealthText"
@onready var health_anim = $"../HealthAnim"

var stamina_cost : int
var attack_cost = 10
var block_cost = 5
var slide_cost = 20
var run_cost = 2
var jump_cost = 30
var max_health = 1200
var old_health = max_health

var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")
		elif stamina > 20:
			emit_signal("mo_stamina")	

var health = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health	
		var difference = health - old_health
		health_text.text = str(difference)
		old_health = health
		if difference < 0:
			health_anim.stop()
			health_anim.play("damage_recieved")
		elif difference > 0: 
			health_anim.stop()
			health_anim.play("health_recieved")
			
func _ready():
	health_text.modulate.a = 0
	Signals.connect("enemy_attack", Callable(self, "_on_damage_recieved"))
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	

func _physics_process(delta):
	stamina_bar.max_value = 100
	stamina_bar.value = stamina
	if stamina < 100:
		stamina += 10 * delta

func _on_damage_recieved(enemy_damage):
	health -= enemy_damage
	if health_bar.value > health_bar.max_value * 0.7:
		health_bar.tint_progress = Color.DARK_GREEN
	elif health_bar.value > health_bar.max_value * 0.4 :
		health_bar.tint_progress = Color.DARK_GOLDENROD
	else:
		health_bar.tint_progress = Color.DARK_RED
	if health <= 0:
		emit_signal("no_health")
	else :
		emit_signal("damage_recieved")

func stamina_consumption():
	stamina -= stamina_cost
	
func _on_health_regen_timeout():
	health += 1
