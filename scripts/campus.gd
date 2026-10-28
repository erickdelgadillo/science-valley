extends Node2D
## Connected floor plan; coordinates are in pixels and all doors are physical gaps.
const WALL_WIDTH := 16.0
const ROOMS := [
    {"name": "LABORATORIO HÚMEDO", "rect": Rect2(-960, -640, 640, 640), "color": Color("#b7d8d2")},
    {"name": "LABORATORIO CENTRAL", "rect": Rect2(-320, -640, 640, 640), "color": Color("#d4e3cd")},
    {"name": "EXTRACCIÓN DE ADN", "rect": Rect2(320, -640, 640, 640), "color": Color("#c9cfee")},
    {"name": "PASILLO", "rect": Rect2(-112, 0, 224, 1152), "color": Color("#e1dfd6")},
    {"name": "BAÑO UNISEX", "rect": Rect2(112, 260, 368, 260), "color": Color("#dfd4e8")},
    {"name": "MI DESPACHO", "rect": Rect2(112, 680, 528, 420), "color": Color("#eddbbd")},
    {"name": "DESPACHO DEL DIRECTOR", "rect": Rect2(-640, 680, 528, 420), "color": Color("#ead3be")}
]

func _ready() -> void:
    _create_walls()
    for room in ROOMS:
        var title := Label.new()
        title.text = room["name"]
        title.position = room["rect"].position + Vector2(20, 24)
        title.add_theme_color_override("font_color", Color("#26343c"))
        title.add_theme_font_size_override("font_size", 22)
        add_child(title)
    queue_redraw()

func _draw() -> void:
    for room in ROOMS:
        draw_rect(room["rect"], room["color"])
        draw_rect(room["rect"], Color("#eae9e5"), false, 2.0)

func _wall(start: Vector2, end: Vector2) -> void:
    var midpoint := (start + end) / 2.0
    var segment := end - start
    var solid := StaticBody2D.new()
    solid.collision_layer = 1
    solid.position = midpoint
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(absf(segment.x) + WALL_WIDTH, absf(segment.y) + WALL_WIDTH)
    collision.shape = shape
    solid.add_child(collision)
    add_child(solid)
    var line := Line2D.new()
    line.points = PackedVector2Array([start, end])
    line.width = WALL_WIDTH
    line.default_color = Color("#465561")
    line.z_index = 3
    add_child(line)

func _create_walls() -> void:
    # Three top laboratories, with doors between adjacent rooms.
    _wall(Vector2(-960, -640), Vector2(960, -640))
    _wall(Vector2(-960, -640), Vector2(-960, 0))
    _wall(Vector2(960, -640), Vector2(960, 0))
    for x in [-320.0, 320.0]:
        _wall(Vector2(x, -640), Vector2(x, -360))
        _wall(Vector2(x, -232), Vector2(x, 0))
    # South facade has an opening from the central lab into the corridor.
    _wall(Vector2(-960, 0), Vector2(-72, 0))
    _wall(Vector2(72, 0), Vector2(960, 0))
    # Corridor left: director's door. Right: bathroom and personal office doors.
    _wall(Vector2(-112, 0), Vector2(-112, 800))
    _wall(Vector2(-112, 900), Vector2(-112, 1152))
    _wall(Vector2(112, 0), Vector2(112, 340))
    _wall(Vector2(112, 440), Vector2(112, 800))
    _wall(Vector2(112, 900), Vector2(112, 1152))
    _wall(Vector2(-112, 1152), Vector2(112, 1152))
    # Bathroom (right of corridor, midway).
    _wall(Vector2(112, 260), Vector2(480, 260))
    _wall(Vector2(480, 260), Vector2(480, 520))
    _wall(Vector2(112, 520), Vector2(480, 520))
    # Office (right, after the bathroom).
    _wall(Vector2(112, 680), Vector2(640, 680))
    _wall(Vector2(640, 680), Vector2(640, 1100))
    _wall(Vector2(112, 1100), Vector2(640, 1100))
    # Supervisor's office directly opposite.
    _wall(Vector2(-640, 680), Vector2(-112, 680))
    _wall(Vector2(-640, 680), Vector2(-640, 1100))
    _wall(Vector2(-640, 1100), Vector2(-112, 1100))
