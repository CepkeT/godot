extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "position", position - Vector2(randf_range(-50, 50), 100), 0.3)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


func _on_detector_body_entered(_body):
	if is_on_floor():
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(self, "position", position - Vector2(0, 100), 0.3)
		tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
		await get_tree().create_timer(0.5).timeout
		queue_free()
	
