extends CharacterBody2D

@export var speed: float = 180.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down"


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	_update_animation(direction)
	move_and_slide()


func _update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0.0 else "left"
		else:
			facing = "down" if direction.y > 0.0 else "up"

		animated_sprite.play("walk_%s" % facing)
	else:
		animated_sprite.play("idle_%s" % facing)
