extends Node
## Autoload of the Trick-or-Treat Town demo.
## - Move: arrow keys or WASD. Day/night: N key or the on-screen button.
## - Remembers which door the player came through (the spawn point of the next scene).
## - Autopilot (run with `-- --autopilot`): walks a fixed route (street -> haunted house ->
##   street -> candy shop -> street, with a day/night change), used to test the demo headless.
##   When an interior door is missing (the Lite pack), it just tours the street and flips
##   day/night. It never pushes into a wall, so the headless test never prints "blocked".

var spawn := "start"
var autopilot := false
var night := true
var scene_id := ""
var _level: Node = null
var _street_visits := 0
var _route: Array = []
var _step := 0
var _wait := -1.0
var _stuck := 0.0
var _last := Vector2.INF

const INTERIOR_ROUTE := [0.3, Vector2(168, 150), Vector2(168, 110), Vector2(90, 110),
	Vector2(250, 110), Vector2(168, 160), Vector2(168, 204)]


func _enter_tree() -> void:
	_bind("move_left", [KEY_LEFT, KEY_A])
	_bind("move_right", [KEY_RIGHT, KEY_D])
	_bind("move_up", [KEY_UP, KEY_W])
	_bind("move_down", [KEY_DOWN, KEY_S])
	_bind("toggle_night", [KEY_N])
	autopilot = "--autopilot" in OS.get_cmdline_user_args()


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action, ev)


func _process(_delta: float) -> void:
	if not autopilot and InputMap.has_action("toggle_night") and Input.is_action_just_pressed("toggle_night"):
		toggle_night()


func toggle_night() -> void:
	night = not night
	if _level and _level.has_method("apply_daynight"):
		_level.apply_daynight()


## Called by each level when it starts (it passes itself).
func begin_scene(id: String, level: Node) -> void:
	_level = level
	scene_id = id
	_step = 0
	_wait = -1.0
	_stuck = 0.0
	_last = Vector2.INF
	if id == "street":
		_street_visits += 1
	print("[demo] scene: ", id)
	_route = _build_route()


func _has_door(kind: String) -> bool:
	if _level == null:
		return false
	var doors := _level.get_node_or_null("Doors")
	if doors == null:
		return false
	for d in doors.get_children():
		if str(d.get("target")).find(kind) != -1:
			return true
	return false


func _build_route() -> Array:
	if not autopilot:
		return []
	if scene_id == "street":
		var has_h := _has_door("haunted")
		var has_s := _has_door("shop")
		match _street_visits:
			1:
				if has_h:
					return [0.5, Vector2(102, 165), Vector2(102, 116)]
				return [0.5, Vector2(300, 170), Vector2(120, 170), "toggle",
					Vector2(250, 182), Vector2(150, 182), "done"]
			2:
				if has_s:
					return ["toggle", 0.3, Vector2(102, 165), Vector2(50, 165), Vector2(50, 116)]
				return ["toggle", Vector2(180, 180), "done"]
			_:
				return [0.3, Vector2(150, 170), "toggle", "done"]
	return INTERIOR_ROUTE.duplicate()


## Direction the player wants to move this frame.
func move_vector(player: Node2D, delta: float) -> Vector2:
	if not autopilot:
		return Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _step >= _route.size():
		return Vector2.ZERO
	var step = _route[_step]
	if step is String:
		if step == "toggle":
			toggle_night()
		elif step == "done":
			print("[demo] route done")
			get_tree().quit()
		_step += 1
		return Vector2.ZERO
	if step is float:
		if _wait < 0.0:
			_wait = step
		_wait -= delta
		if _wait <= 0.0:
			_wait = -1.0
			_step += 1
		return Vector2.ZERO
	var to: Vector2 = step - player.position
	if to.length() < 2.0:
		_step += 1
		_stuck = 0.0
		return Vector2.ZERO
	_stuck = _stuck + delta if player.position.distance_to(_last) < 0.02 else 0.0
	_last = player.position
	if _stuck > 1.0:
		print("[demo] blocked at ", player.position.round(), " going to ", step)
		_stuck = 0.0
		_step += 1
	return to.normalized()
