extends SceneTree
## Builds the Trick-or-Treat Town demo scenes from godot_build/escenas.json
## (written by hw_demo.py) and saves them with ResourceSaver, so the .tscn use Godot's
## own format.
##     Godot --headless --path godot --script res://../godot_build/build.gd
##
## The art is NOT in the repo: every texture / tileset / SpriteFrames lives under
## res://assets/ (the folder where the buyer unzips the Lite or the Complete pack).
## Before every load() this script checks the resource exists; if it is missing the item,
## layer, collider or whole scene is skipped, with no error. So the same project runs with
## the Complete (street + haunted house + candy shop + day/night) and with the Lite
## (street + day/night only, the interior doors simply never appear).

var _built := {}
var _planned := {}


func _initialize() -> void:
	var json_path := ProjectSettings.globalize_path("res://").path_join("../godot_build/escenas.json").simplify_path()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	# Plan which scenes will be built (their required art is present), so a door only appears
	# when the scene it leads to will exist. A scene builds later than the ones it links to.
	_planned["res://scenes/player.tscn"] = true
	for scene in data["scenes"]:
		var ok := true
		for req in scene.get("requires", []):
			if not _exists(req):
				ok = false
		_planned[scene["path"]] = ok
	_build_player(data.get("player", {}))
	for scene in data["scenes"]:
		_build_level(scene)
	quit()


func _exists(path) -> bool:
	return typeof(path) == TYPE_STRING and path != "" and ResourceLoader.exists(path)


func _own(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		if child.scene_file_path.is_empty():
			_own(child, root)


func _save(root: Node, path: String) -> void:
	_own(root, root)
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	if err == OK:
		_built[path] = true
	print("[build] ", path, ": ", error_string(err))
	root.free()


func _rect_shape(r: Array) -> CollisionShape2D:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(r[2], r[3])
	shape.shape = rect
	shape.position = Vector2(r[0] + r[2] / 2.0, r[1] + r[3] / 2.0)
	return shape


func _build_player(pdef: Dictionary) -> void:
	var body := CharacterBody2D.new()
	body.name = "Player"
	body.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	body.set_script(load("res://scripts/player.gd"))
	body.add_to_group("player", true)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	var frames = pdef.get("frames", "")
	if _exists(frames):
		sprite.sprite_frames = load(frames)
		sprite.animation = &"idle_down"
		sprite.autoplay = "idle_down"
	sprite.centered = false
	sprite.offset = Vector2(-8, -21)
	body.add_child(sprite)
	var feet := _rect_shape([-4, -4, 8, 4])
	feet.name = "Feet"
	body.add_child(feet)
	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(0, -8)
	body.add_child(camera)
	_save(body, "res://scenes/player.tscn")


func _tile_layer(def: Dictionary):
	if not _exists(def["tileset"]):
		return null
	var layer := TileMapLayer.new()
	layer.name = def["name"]
	layer.tile_set = load(def["tileset"])
	for c in def["cells"]:
		layer.set_cell(Vector2i(c[0], c[1]), c[2], Vector2i(c[3], c[4]))
	return layer


func _build_level(scene: Dictionary) -> void:
	for req in scene.get("requires", []):
		if not _exists(req):
			print("[build] skip ", scene["path"], " (missing ", req, ")")
			return
	var root := Node2D.new()
	root.name = String(scene["id"]).capitalize()
	root.set_script(load("res://scripts/level.gd"))
	root.set("scene_id", scene["id"])
	root.set("map_size", Vector2i(scene["size"][0], scene["size"][1]))
	for def in scene["layers"]:
		if not def.get("above", false):
			var layer = _tile_layer(def)
			if layer != null:
				root.add_child(layer)
	if scene.get("canvasmod", false):
		var cm := CanvasModulate.new()
		cm.name = "DayNight"
		cm.color = Color(1, 1, 1)
		root.add_child(cm)
	# y-sorted world: everything that stands on the ground, in the order of the screenshots
	var world := Node2D.new()
	world.name = "World"
	world.y_sort_enabled = true
	root.add_child(world)
	var names := {}
	for item in scene["world"]:
		var is_actor: bool = item.has("frames")
		var tex = item.get("frames", item.get("texture", ""))
		if not _exists(tex):
			continue
		var node: Node2D
		var base := floorf(item["pos"][1])
		if is_actor:
			var actor := AnimatedSprite2D.new()
			actor.sprite_frames = load(tex)
			var anim := StringName(item["anim"])
			if actor.sprite_frames.has_animation(anim):
				actor.animation = anim
				actor.autoplay = item["anim"]
				actor.frame = int(item["frame"]) % maxi(1, actor.sprite_frames.get_frame_count(anim))
			actor.centered = false
			actor.offset = Vector2(item["offset"][0], item["top"] - base)
			node = actor
		else:
			var sprite := Sprite2D.new()
			sprite.texture = load(tex)
			sprite.centered = false
			sprite.offset = Vector2(item["offset"][0], item["top"] - base)
			var night = item.get("night", "")
			if _exists(night):
				sprite.set_meta("day_tex", tex)
				sprite.set_meta("night_tex", night)
			node = sprite
		node.position = Vector2(item["pos"][0], base)
		var n: String = item["name"]
		names[n] = names.get(n, 0) + 1
		node.name = n if names[n] == 1 else "%s-%d" % [n, names[n]]
		world.add_child(node)
	if _built.get("res://scenes/player.tscn", false):
		world.add_child(load("res://scenes/player.tscn").instantiate())
	for def in scene["layers"]:
		if def.get("above", false):
			var layer = _tile_layer(def)
			if layer != null:
				root.add_child(layer)
	var walls := StaticBody2D.new()
	walls.name = "Colliders"
	root.add_child(walls)
	for r in scene["colliders"]:
		var req = r.get("requires", null)
		if req != null and not _exists(req):
			continue
		walls.add_child(_rect_shape(r["rect"]))
	var doors := Node2D.new()
	doors.name = "Doors"
	root.add_child(doors)
	for d in scene["doors"]:
		if not _planned.get(d["target"], false):
			continue
		var door := Area2D.new()
		door.name = "Door"
		door.set_script(load("res://scripts/door.gd"))
		door.set("target", d["target"])
		door.set("spawn", d["spawn"])
		door.add_child(_rect_shape(d["rect"]))
		doors.add_child(door)
	var spawns := Node2D.new()
	spawns.name = "Spawns"
	root.add_child(spawns)
	for s in scene["spawns"]:
		var marker := Marker2D.new()
		marker.name = s["name"]
		marker.position = Vector2(s["pos"][0], s["pos"][1])
		marker.set_meta("facing", s["facing"])
		spawns.add_child(marker)
	_save(root, scene["path"])
