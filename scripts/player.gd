extends CharacterBody2D

const OUTSIDE_SPRITE_FRAMES := preload("res://assets/characters/player_scientist_frames.tres")
const LAB_SPRITE_FRAMES := preload("res://assets/characters/player_scientist_labcoat_frames.tres")

@export var speed: float = 180.0

@export var starts_in_lab := true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down"
var is_in_lab := false


func _ready() -> void:
	set_lab_outfit(starts_in_lab)


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


func set_lab_outfit(enabled: bool) -> void:
	if is_in_lab == enabled and animated_sprite.sprite_frames != null:
		return

	is_in_lab = enabled
	animated_sprite.sprite_frames = LAB_SPRITE_FRAMES if enabled else OUTSIDE_SPRITE_FRAMES
	_update_animation(velocity.normalized())
