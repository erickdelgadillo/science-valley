extends SceneTree

func _initialize() -> void:
    call_deferred("_run_checks")

func _run_checks() -> void:
    var scene: PackedScene = load("res://institute_layout.tscn")
    if scene == null:
        push_error("Institute scene cannot be loaded")
        quit(1)
        return
    var building: Node2D = scene.instantiate()
    root.add_child(building)
    var player: CharacterBody2D = building.get_node("Player")
    if player.get_node_or_null("AnimatedSprite2D") == null:
        push_error("Animated scientist sprite was lost")
        quit(1)
        return
    if not player.has_method("set_lab_outfit"):
        push_error("Existing lab coat mechanism is missing")
        quit(1)
        return
    for floor_number in range(2):
        var floor: Node2D = building.get_node("Floor")
        var rooms: Node2D = floor.get_node("Rooms")
        if rooms.get_child_count() != (5 if floor_number == 0 else 9):
            push_error("Wrong number of editable rooms")
            quit(1)
            return
        if floor_number == 0:
            if floor.get_node_or_null("Garden") == null or rooms.get_node("WetLab").get_meta("room_size") != Vector2(1152,640):
                push_error("Wrong wet laboratory or garden")
                quit(1)
                return
        else:
            if floor.get_node_or_null("Garden") != null:
                push_error("Upper floor should not contain a garden")
                quit(1)
                return
            if rooms.get_node("GeneralLab").get_meta("room_size") != Vector2(576,640):
                push_error("Wrong general laboratory size")
                quit(1)
                return
        building.switch_floor()
    if building.current_floor != 0:
        push_error("Floor transition did not return to ground floor")
        quit(1)
        return
    print("PASS: editable floors, laboratory/outfit and transitions")
    quit(0)
