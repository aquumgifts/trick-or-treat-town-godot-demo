extends Node2D
## A level: places the player on the spawn point of the door it came through, keeps the camera
## inside the map, builds the on-screen Day/Night button, and applies the day/night look.

@export var scene_id := "street"
@export var map_size := Vector2i(432, 240)


func _ready() -> void:
	var player: CharacterBody2D = get_node_or_null("World/Player")
	var marker: Marker2D = get_node_or_null("Spawns/" + Demo.spawn)
	if marker == null:
		marker = get_node_or_null("Spawns/start")
	if player and marker:
		player.position = marker.position
		player.face(marker.get_meta("facing", "down"))
	if player:
		var camera: Camera2D = player.get_node_or_null("Camera")
		if camera:
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = map_size.x
			camera.limit_bottom = map_size.y
			camera.reset_smoothing()
	_make_ui()
	apply_daynight()
	Demo.begin_scene(scene_id, self)


func _make_ui() -> void:
	if get_node_or_null("UI"):
		return
	var layer := CanvasLayer.new()
	layer.name = "UI"
	var btn := Button.new()
	btn.text = "Day / Night (N)"
	btn.position = Vector2(8, 8)
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(func(): Demo.toggle_night())
	layer.add_child(btn)
	add_child(layer)


func apply_daynight() -> void:
	var cm: CanvasModulate = get_node_or_null("DayNight")
	if cm:
		cm.color = Color(0.40, 0.44, 0.72) if Demo.night else Color(1, 1, 1)
	var world := get_node_or_null("World")
	if world:
		for n in world.get_children():
			if n is Sprite2D and n.has_meta("night_tex"):
				var p: String = n.get_meta("night_tex") if Demo.night else n.get_meta("day_tex")
				if ResourceLoader.exists(p):
					n.texture = load(p)
