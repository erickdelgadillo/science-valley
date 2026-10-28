extends SceneTree

func _initialize() -> void:
    var scene := load("res://campus.tscn") as PackedScene
    if scene == null:
        push_error("Campus scene unavailable")
        quit(1)
        return
    var campus := scene.instantiate()
    root.add_child(campus)
    var player := campus.get_node_or_null("Player") as CharacterBody2D
    if player == null or player.get_node_or_null("Camera2D") == null:
        push_error("Player or camera missing")
        quit(1)
        return
    if player.get_node_or_null("CollisionShape2D") == null:
        push_error("Player collision missing")
        quit(1)
        return
    if player.position != Vector2(0, -200):
        push_error("Player spawn location changed")
        quit(1)
        return
    var script: Script = campus.get_script()
    if script == null or script.get_script_constant_map().get("ROOMS", []).size() != 7:
        push_error("Expected seven connected spaces")
        quit(1)
        return
    print("PASS: campus scene, seven spaces, player and camera")
    quit(0)
