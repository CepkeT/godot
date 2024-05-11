extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	CHASE,
	TAKE_HIT,
	DEATH
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			ATTACK2:
				attack2_state()
			ATTACK3:
				attack3_state()
			CHASE:
				chase_state() 
			TAKE_HIT:
				take_hit_state()
			DEATH:
				death_state()
			

@onready var animEnemy: AnimationPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var attackRange = $AttackDirections/AttackRange
@onready var attack_range = $AttackDirections/AttackRange/Attack1
	
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var direction
var damage = 20

var cooldowns = {
  ATTACK: false,
  ATTACK2: false,
  ATTACK3: false
}

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	player = Global.player_pos
	attack_range.disabled = false
	state = CHASE
	move_and_slide()

func _on_attack_range_body_entered(body):
		random_attack()
		
func _on_attack_range_body_exited(body):
	if not attackRange.has_overlapping_bodies():
		state = IDLE

func random_attack():
	randomize()
	var attack_states = [ATTACK, ATTACK2, ATTACK3].filter(func(x): return not cooldowns[x])
	if attack_states.size() > 0:
		var random_attack = attack_states[randi() % attack_states.size()]
		state = random_attack
		
func idle_state():
	animEnemy.play("Idle")	
	state = CHASE

func attack_state():
	cooldowns[ATTACK] = true
	animEnemy.play("Attack")
	await animEnemy.animation_finished 
	
	start_cooldown_timer(3.5, ATTACK)
	state = IDLE
	
func attack2_state():
	cooldowns[ATTACK2] = true
	animEnemy.play("Attack2")
	await animEnemy.animation_finished 
	
	start_cooldown_timer(7, ATTACK2)
	state = IDLE
	
func attack3_state():
	cooldowns[ATTACK3] = true
	animEnemy.play("Attack3")
	await animEnemy.animation_finished
	
	start_cooldown_timer(15, ATTACK3)
	state = IDLE
	
func take_hit_state():
	damage_anim()
	animEnemy.play("Take_hit")
	await animEnemy.animation_finished

func death_state():
	animEnemy.stop()
	animEnemy.play("Death")
	await animEnemy.animation_finished
	queue_free()
	Signals.emit_signal("enemy_died", position)

func start_cooldown_timer(time, attack):
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	var callable: Callable = Callable(self, "_on_cooldown_timeout").bind(attack)
	timer.connect("timeout", callable)
	timer.name = "CooldownTimer" + str(attack)
	timer.start()

func _on_cooldown_timeout(attack: int) -> void:
	cooldowns[attack] = false
	if attackRange.has_overlapping_bodies():
		attack_range.disabled = true
		await get_tree().create_timer(0.1).timeout
		attack_range.disabled = false
	var timer := get_node_or_null("CooldownTimer" + str(attack))
	if timer:
		timer.queue_free()
			
		
func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirections.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirections.rotation_degrees = 0
	#$AttackDirections/AttackRange.rotation = direction.angle()
func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage )

func _on_mob_health_no_health():
	state = DEATH

func _on_mob_health_damage_recieved():
	state = IDLE
	state = TAKE_HIT

func damage_anim():
	direction = (player - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 200
		velocity.y -= 100
	elif direction.x > 0 :
		velocity.x -= 200
		velocity.y -= 100
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.1)



