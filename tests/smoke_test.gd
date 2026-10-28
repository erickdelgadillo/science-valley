extends SceneTree

func _initialize() -> void:
    var packed := load("res://lab.tscn") as PackedScene
    if packed == null:
        push_error("Main laboratory scene could not be loaded")
        quit(1)
        return
    var lab := packed.instantiate()
    root.add_child(lab)
    var player := lab.get_node_or_null("Player") as CharacterBody2D
    var camera := lab.get_node_or_null("Player/Camera2D") as Camera2D
    var collision := lab.get_node_or_null("Player/CollisionShape2D") as CollisionShape2D
    if player == null or camera == null or collision == null:
        push_error("Main scene is missing Player, Camera2D, or CollisionShape2D")
        quit(1)
        return
    if player.get_script() == null or player.speed <= 0.0:
        push_error("Player movement script or speed is invalid")
        quit(1)
        return
    for input_name in ["move_up", "move_down", "move_left", "move_right"]:
        if not InputMap.has_action(input_name):
            push_error("Missing movement input action: " + input_name)
            quit(1)
            return
    print("PASS: lab scene, movement, input actions, camera, and collision")
    quit(0)
