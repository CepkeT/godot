extends Area2D


# Called when the node enters the scene tree for the first time.

#к своей позиции по вектору за 0,3 секунды

func _on_body_entered(body):
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(self, "position", position - Vector2(0, 25), 0.3)
		tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
		tween.tween_callback(queue_free)
		body.gold += 10

