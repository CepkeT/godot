extends Area2D

func _ready():
	$AttackDirections/DamageBox/HitBox/CollisionShape2D.disabled = true
	$AttackDirections/DamageBox/HitBox/CollisionShape2D2.disabled = true
	$AttackDirections/DamageBox/HitBox/CollisionShape2D3.disabled = true
