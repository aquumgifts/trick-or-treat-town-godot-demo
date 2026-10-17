extends CharacterBody2D
## The player: walks in 4 directions with the player-witch sheet (idle_<dir> / walk_<dir>).

const SPEED := 60.0

var facing := "down"

@onready var sprite: AnimatedSprite2D = $Sprite


func _physics_process(delta: float) -> void:
	var dir := Demo.move_vector(self, delta)
	velocity = dir * SPEED
	move_and_slide()
	if dir == Vector2.ZERO:
		_play("idle_" + facing)
		return
	if absf(dir.x) > absf(dir.y):
		facing = "right" if dir.x > 0.0 else "left"
	else:
		facing = "down" if dir.y > 0.0 else "up"
	_play("walk_" + facing)


func face(direction: String) -> void:
	facing = direction
	_play("idle_" + facing)


func _play(animation: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(animation):
		return
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)
