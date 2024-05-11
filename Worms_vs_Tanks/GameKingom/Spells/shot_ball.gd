extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
var SPEED = 250
var GRAVITY = 250



var velocity = Vector2.ZERO
var direction = 1
#var damage_basic = 10
#var damage_multiplier = 200
#var attack_current

func _ready():
	if direction == -1:
		anim.flip_h = true

func _physics_process(delta):
	velocity.x = SPEED * direction
	#velocity.y += GRAVITY * delta
	translate(velocity * delta)
	

func _on_visible_on_screen_notifier_2d_tree_exited():
	queue_free()
	
func _on_area_entered(_area):
	animPlayer.play("boom")
	await animPlayer.animation_finished
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
