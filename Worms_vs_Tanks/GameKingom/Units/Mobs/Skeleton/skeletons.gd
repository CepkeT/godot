extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var speed = 100
var alive = true
@onready var anim = $AnimatedSprite2D


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	if alive == true:
		if chase == true:
			velocity.x = direction.x * speed
			anim.play("Run")
		else: 
			velocity.x = 0
			anim.play("Idle")
			
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

		
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true


func _on_detector_body_exited(body):
	if body.name == "Player":
		chase = false


func _on_death_body_entered(body):
	if body.name == "Player":
		body.velocity.y -= 100
		_death()
		
func _on_hit_body_entered(body):
	if body.name == "Player":
		if alive == true:
			body.health -= 40
		_death()

func _on_hit_body_exited(body):
	if body.name == "Player":
		alive = true
		chase = true
		

func _death():
	alive = false
	anim.play("Death")
	await anim.animation_finished
	queue_free()	

