extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	CHASE,
	TAKE_HIT,
	DEATH,
	RECOVER
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			CHASE:
				chase_state() 
			TAKE_HIT:
				take_hit_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()

@onready var animEnemy = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var direction
var cooldown_attack1 = false
var cooldown_attack2 = false
var cooldown_attack3 = false
var damage = 20


func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

func _on_player_position_update(player_pos):
	player = player_pos

func _on_attack_range_body_entered(_body):
	state = ATTACK

func _on_attack_range_body_exited(_body):
	state = ATTACK

func idle_state():
	animEnemy.play("Idle")	
	state = CHASE

var cooldown_timer = Timer.new() # создаем новый таймер

func start_cooldown(duration):
	if cooldown_timer.is_inside_tree(): # проверяем, добавлен ли таймер в дерево сцены
		cooldown_timer.stop() # если да, останавливаем таймер
	else:
		add_child(cooldown_timer) # если нет, добавляем таймер в дерево сцены
		cooldown_timer.wait_time = duration # устанавливаем длительность кулдауна
		cooldown_timer.one_shot = true # устанавливаем таймер на однократное срабатывание
		cooldown_timer.start() # начинаем отсчет


func attack_state():
	#if !cooldown_timer.is_stopped() or animEnemy.current_animation == "Attack":
		#pass
	#else:
		#animEnemy.play("Attack")
		#await  animEnemy.animation_finished
		#$AttackDirections/AttackRange/Attack1.disabled = true
		#start_cooldown(5)
		#state = RECOVER
		
	animEnemy.play("Attack")
	await animEnemy.animation_finished
	state = RECOVER	

func take_hit_state():
	animEnemy.play("Take_hit")
	await animEnemy.animation_finished
	state = IDLE

func death_state():
	animEnemy.stop()
	animEnemy.play("Death")
	await animEnemy.animation_finished
	queue_free()

func recover_state():
	animEnemy.play("recover")
	await animEnemy.animation_finished
	state = IDLE

func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirections.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirections.rotation_degrees = 0


func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage )

func _on_mob_health_no_health():
	state = DEATH


func _on_mob_health_damage_recieved():
	state = IDLE
	state = TAKE_HIT
