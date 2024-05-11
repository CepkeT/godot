extends CharacterBody2D

@onready var animPlayer = $AnimationPlayer
@onready var stats = $Stats
const SHOT_BALL = preload("res://GameKingom/Spells/shot_ball.tscn")

enum {
	MOVE,
	JUMP,
	ATTACK,
	ATTACK2,
	COMBO,
	CRIT,
	SHOT,
	BLOCK,
	SLIDE,
	DAMAGE,
	DEATH
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gold = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var damage_basic = 10
var damage_multiplier = 1
var attack_current
var recovery = false
var enemy

func  _ready():
	Signals.connect("enemy_attack", Callable(self, "_on_damage_recieved"))
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state()	
		JUMP:
			jump_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		COMBO:
			combo_state()		
		CRIT:
			crit_state()
		SHOT:
			shot_state()
		BLOCK:
			block_state()		
		SLIDE:
			slide_state()		
		DAMAGE:
			damage_state()		
		DEATH:
			death_state()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if velocity.y > 0:
		animPlayer.play("Fall")
		if position.y > 1242:
			state = DEATH
		
	Global.player_damage = damage_basic * damage_multiplier

	move_and_slide()
	
	Global.player_pos = self.position

func move_state():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		$AttackDirection1.rotation_degrees = 180
		$Marker2D.position.x = abs($Marker2D.position.x) * -1
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false	
		$AttackDirection1.rotation_degrees = 0
		$Marker2D.position.x = abs($Marker2D.position.x) 
	if Input.is_action_pressed("run"):
		run_speed = 1.5
	else:
		run_speed = 1
	
	if Input.is_action_pressed("jump") :
		stats.stamina_cost = stats.jump_cost
		if stats.stamina > stats.stamina_cost:
			state = JUMP
			
	if Input.is_action_just_pressed("attack"):
		stats.stamina_cost = stats.attack_cost
		if(attack_cooldown == false) and stats.stamina > stats.stamina_cost:
			state = ATTACK
		
	if Input.is_action_just_pressed("crit_attack"):
		stats.stamina_cost = stats.attack_cost
		if stats.stamina > stats.stamina_cost:
			state = ATTACK2
	
	if Input.is_action_just_pressed("shot"):
		state = SHOT
		
	if Input.is_action_pressed("block") and velocity.x != 0:
		stats.stamina_cost = stats.slide_cost
		if stats.stamina > stats.stamina_cost:
			state = SLIDE
			
	elif Input.is_action_pressed("block") and velocity.x == 0:
		stats.stamina_cost = stats.block_cost
		if stats.stamina > stats.stamina_cost:
			animPlayer.play("Block")
			state = BLOCK


			
func jump_state():
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animPlayer.play("Jump")
		await animPlayer.animation_finished
		state = MOVE

func combo_bool():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func cooldown_attack():
	attack_cooldown = true
	await get_tree().create_timer(0.3).timeout
	attack_cooldown = false

func attack_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	cooldown_attack()
	state = MOVE

func attack2_state():
	stats.stamina_cost = stats.attack_cost
	velocity.x = 0
	damage_multiplier = 2
	animPlayer.play("CritAttack")
	await animPlayer.animation_finished
	state = MOVE

func combo_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 1.2
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = CRIT
	velocity.x = 0
	animPlayer.play("Combo")
	await animPlayer.animation_finished
	state = MOVE

func crit_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 1.6
	velocity.x = 0
	animPlayer.play("CritAttack")
	await animPlayer.animation_finished
	state = MOVE

func shot_state():
	animPlayer.play("Shot")
	await animPlayer.animation_finished
	shoot()
	damage_multiplier = 2.5
	velocity.x = 0
	
	state = MOVE

func block_state():
	velocity.x = 0
	#animPlayer.play("Block")
	if Input.is_action_just_released("block") or recovery:
		state = MOVE

func slide_state():
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = MOVE

func damage_state():
	
	animPlayer.play("Hit")
	await animPlayer.animation_finished
	
	state = MOVE

func death_state():
	velocity.x = 0
	#animPlayer.stop()
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://GameKingom/Menu/menu_kingdom.tscn").call_deferred()

func _on_damage_recieved(enemy_damage):
	if state == BLOCK:
		enemy_damage /= 5
		stats.stamina -= stats.block_cost * 1.5
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_anim()
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH		

func  shoot():
	var shot_ball = SHOT_BALL.instantiate()
	shot_ball.direction = sign($Marker2D.global_position.x)	
	shot_ball.position = $Marker2D.global_position
	call_deferred("add_child", shot_ball)
	state = MOVE


func _on_stats_no_stamina():
	recovery = true


func _on_stats_mo_stamina():
	recovery = false

func damage_anim():
	velocity.x = 0
	self.modulate = Color (1, 0, 0, 1)
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 200
		velocity.y -= 100
	else :
		velocity.x -= 200
		velocity.y -= 100
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.1)
	tween.parallel().tween_property(self, "modulate", Color (1, 1, 1, 1), 0.3)
