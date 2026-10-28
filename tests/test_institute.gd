extends SceneTree

func _initialize() -> void:
    var packed: PackedScene = load("res://institute.tscn")
    if packed == null:
        push_error("New institute scene unavailable")
        quit(1)
        return
    var institute: Node2D = packed.instantiate()
    root.add_child(institute)
    var player: CharacterBody2D = institute.get_node("Player")
    if player.get_node_or_null("CollisionShape2D") == null or player.get_node_or_null("Camera2D") == null:
        push_error("Player missing camera or collision")
        quit(1)
        return
    if not InputMap.has_action("interact"):
        push_error("Interaction input is absent")
        quit(1)
        return
    var code: Script = institute.get_script()
    var constants: Dictionary = code.get_script_constant_map()
    var floor_zero: Array = constants["FLOOR_ZERO"]
    var floor_one: Array = constants["FLOOR_ONE"]
    if floor_zero.size() != 5 or floor_one.size() != 8:
        push_error("Unexpected room inventory")
        quit(1)
        return
    if floor_zero[0]["rect"].size != Vector2(1152, 640):
        push_error("Wet laboratory size changed")
        quit(1)
        return
    if floor_one[0]["rect"].size != Vector2(576, 640) or floor_one[1]["rect"].size != Vector2(576, 640):
        push_error("Upper laboratory sizes changed")
        quit(1)
        return
    if institute.current_floor != 0:
        push_error("Wrong initial floor")
        quit(1)
        return
    institute.switch_floor()
    if institute.current_floor != 1:
        push_error("Unable to change floors")
        quit(1)
        return
    institute.switch_floor()
    if institute.current_floor != 0:
        push_error("Unable to return to floor zero")
        quit(1)
        return
    print("PASS: dimensions, floor transport, input, and player")
    quit(0)
