extends SceneTree

func _initialize() -> void:
    var scene: PackedScene = load("res://institute_layout.tscn")
    if scene == null:
        push_error("Institute scene cannot be loaded")
        quit(1)
        return
    var building: Node2D = scene.instantiate()
    root.add_child(building)
    var player: CharacterBody2D = building.get_node("Player")
    if player.get_node_or_null("AnimatedSprite2D") == null:
        push_error("Existing animated scientist sprite was lost")
        quit(1)
        return
    var script: Script = building.get_script()
    var data: Dictionary = script.get_script_constant_map()
    if (data["ROOMS_0"] as Array).size() != 5 or (data["ROOMS_1"] as Array).size() != 9:
        push_error("Room counts differ from the approved floor plan")
        quit(1)
        return
    if (data["ROOMS_0"] as Array)[0]["rect"].size != Vector2(1152,640):
        push_error("Wet laboratory dimensions differ")
        quit(1)
        return
    building.switch_floor()
    if building.current_floor != 1:
        push_error("Stairs do not change floors")
        quit(1)
        return
    building.switch_floor(true)
    if building.current_floor != 0:
        push_error("Elevator does not return to ground floor")
        quit(1)
        return
    if not player.has_method("set_lab_outfit"):
        push_error("Existing lab coat change method missing")
        quit(1)
        return
    print("PASS: new architecture, scientist animation and floor transitions")
    quit(0)
