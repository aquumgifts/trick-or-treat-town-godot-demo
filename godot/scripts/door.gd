extends Area2D
## A door: when the player walks into it, load the target scene and tell it where to
## put the player.

@export_file("*.tscn") var target := ""
@export var spawn := ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Demo.spawn = spawn
		get_tree().change_scene_to_file.call_deferred(target)
