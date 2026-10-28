extends Node2D
## Floor geometry is authored in editable PackedScenes, not generated at runtime.
const FLOORS: Array[PackedScene] = [
    preload("res://scenes/floors/floor_0.tscn"),
    preload("res://scenes/floors/floor_1.tscn")
]
var current_floor: int = 0
@onready var player: CharacterBody2D = $Player
@onready var active_floor: Node2D = $Floor
var status_label: Label

func _ready() -> void:
    status_label = Label.new()
    status_label.position = Vector2(-40,-115)
    status_label.add_theme_color_override("font_color", Color("#26343c"))
    status_label.add_theme_font_size_override("font_size", 18)
    player.add_child(status_label)
    _update_outfit()

func _process(_delta: float) -> void:
    _update_outfit()
    status_label.text = "P%d · E: escaleras/ascensor" % current_floor

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if player.position.distance_to(Vector2(95,688)) < 95.0:
            switch_floor(false)
        elif player.position.distance_to(Vector2(1057,688)) < 95.0:
            switch_floor(true)

func switch_floor(using_elevator: bool = false) -> void:
    var next_floor: int = 1 - current_floor
    remove_child(active_floor)
    active_floor.queue_free()
    active_floor = FLOORS[next_floor].instantiate()
    active_floor.name = "Floor"
    add_child(active_floor)
    move_child(active_floor, 0)
    current_floor = next_floor
    player.position = Vector2(1057 if using_elevator else 95, 688)
    _update_outfit()

func _update_outfit() -> void:
    var inside_lab := false
    var rooms: Node2D = active_floor.get_node("Rooms")
    for room in rooms.get_children():
        if not room.get_meta("is_lab", false):
            continue
        var size: Vector2 = room.get_meta("room_size", Vector2.ZERO)
        if Rect2(room.position, size).has_point(player.position):
            inside_lab = true
            break
    player.set_lab_outfit(inside_lab)
