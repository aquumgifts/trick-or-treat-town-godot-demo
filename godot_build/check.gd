extends SceneTree
## Inspects the Trick-or-Treat Town demo scenes that were built: painted cells, world
## nodes, colliders and doors. Scenes that were not built (the Lite pack has no interiors)
## are simply reported as absent, with no error.
##     Godot --headless --path godot --script res://../godot_build/check.gd

func _initialize() -> void:
	for path in ["res://scenes/street.tscn", "res://scenes/haunted.tscn", "res://scenes/shop.tscn"]:
		if not ResourceLoader.exists(path):
			print("[check] ", path, " absent")
			continue
		var scene: Node = load(path).instantiate()
		var layers := []
		for child in scene.get_children():
			if child is TileMapLayer:
				layers.append("%s=%d" % [child.name, child.get_used_cells().size()])
		var world: Node = scene.get_node("World")
		var sprites := 0
		var actors := 0
		for n in world.get_children():
			if n is Sprite2D:
				sprites += 1
			elif n is AnimatedSprite2D:
				actors += 1
				if not n.sprite_frames.has_animation(n.animation):
					print("[check] FALTA animacion ", n.name, " ", n.animation)
		print("[check] ", path, " ", layers, " sprites=", sprites, " personajes=", actors,
			" colisiones=", scene.get_node("Colliders").get_child_count(), " puertas=", scene.get_node("Doors").get_child_count())
		scene.free()
	quit()
