extends Node2D
## Two floor institute. One design metre is 32 Godot pixels.
const METRE := 32.0
const WALL := 12.0
const HALL := Color("#e5e3db")
const WALL_COLOR := Color("#485763")
const FLOOR_ZERO := [
    {"name": "LABORATORIO HÚMEDO", "rect": Rect2(-576, -640, 1152, 640), "color": Color("#b9ddd4"), "door": "bottom"},
    {"name": "SIN ASIGNAR 1", "rect": Rect2(-576, 128, 480, 288), "color": Color("#f1f0eb"), "door": "right"},
    {"name": "SIN ASIGNAR 2", "rect": Rect2(96, 128, 480, 288), "color": Color("#f1f0eb"), "door": "left"},
    {"name": "SIN ASIGNAR 3", "rect": Rect2(-576, 416, 480, 544), "color": Color("#f1f0eb"), "door": "right"},
    {"name": "SIN ASIGNAR 4", "rect": Rect2(96, 416, 480, 544), "color": Color("#f1f0eb"), "door": "left"}
]
const FLOOR_ONE := [
    {"name": "LABORATORIO GENERAL", "rect": Rect2(-576, -640, 576, 640), "color": Color("#d6e9cb"), "door": "bottom"},
    {"name": "EXTRACCIÓN DE ADN", "rect": Rect2(0, -640, 576, 640), "color": Color("#ccd6f1"), "door": "bottom"},
    {"name": "REACTIVOS Y CONSUMIBLES", "rect": Rect2(-576, 128, 240, 608), "color": Color("#e4d5ea"), "door": "top"},
    {"name": "ULTRACONGELADORES", "rect": Rect2(-336, 128, 240, 608), "color": Color("#cbdcf0"), "door": "top"},
    {"name": "ALMACÉN DE CAMPO", "rect": Rect2(96, 128, 480, 288), "color": Color("#c8dcda"), "door": "left"},
    {"name": "BAÑO UNISEX", "rect": Rect2(96, 416, 480, 160), "color": Color("#e5dbed"), "door": "left"},
    {"name": "SIN ASIGNAR", "rect": Rect2(96, 576, 480, 160), "color": Color("#f1f0eb"), "door": "left"},
    {"name": "MI DESPACHO", "rect": Rect2(96, 736, 480, 224), "color": Color("#f0ddbd"), "door": "left"}
]
# On level 1, the office in the west wing is at the corridor's end.
const DIRECTOR := {"name": "DESPACHO DEL DIRECTOR", "rect": Rect2(-576, 736, 480, 224), "color": Color("#ead4c1"), "door": "right"}
var current_floor: int = 0
var constructed: Node2D
var prompt: Label

func _ready() -> void:
    constructed = Node2D.new()
    constructed.name = "GeneratedFloor"
    add_child(constructed)
    prompt = Label.new()
    prompt.name = "FloorInfo"
    prompt.position = Vector2(-72, -135)
    prompt.add_theme_font_size_override("font_size", 18)
    get_node("Player").add_child(prompt)
    _build()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and _near_transport():
        switch_floor()

func _near_transport() -> bool:
    var p: Vector2 = get_node("Player").position
    return (p - Vector2(-480, 64)).length() < 110 or (p - Vector2(480, 64)).length() < 110

func switch_floor() -> void:
    current_floor = 1 - current_floor
    get_node("Player").position = Vector2(0, 64)
    _build()

func _build() -> void:
    for child in constructed.get_children():
        constructed.remove_child(child)
        child.queue_free()
    var rooms: Array = FLOOR_ZERO.duplicate() if current_floor == 0 else FLOOR_ONE.duplicate()
    if current_floor == 1:
        rooms.append(DIRECTOR)
    _tile(Rect2(-576, 0, 1152, 128), HALL, "DISTRIBUIDOR")
    _tile(Rect2(-96, 128, 192, 1056), HALL, "PASILLO")
    for room in rooms:
        _tile(room["rect"], room["color"], room["name"])
        _outline(room["rect"], room["door"])
    if current_floor == 0:
        _tile(Rect2(-576, 1184, 1152, 640), Color("#abd3a5"), "PATIO EXTERIOR")
        # South corridor opens into the only garden entrance.
        _line(Vector2(-576, 1184), Vector2(-64, 1184))
        _line(Vector2(64, 1184), Vector2(576, 1184))
        _line(Vector2(-576, 1184), Vector2(-576, 1824))
        _line(Vector2(576, 1184), Vector2(576, 1824))
        _line(Vector2(-576, 1824), Vector2(576, 1824))
    else:
        _line(Vector2(-96, 1184), Vector2(96, 1184))
    _line(Vector2(-96, 128), Vector2(-96, 960 if current_floor == 0 else 960), false)
    _line(Vector2(96, 128), Vector2(96, 960))
    # Gap in the distributor boundary for the corridor.
    _line(Vector2(-576, 128), Vector2(-96, 128), false)
    _line(Vector2(96, 128), Vector2(576, 128), false)
    _transport(-480, "ESCALERA", Color("#bfd3e8"))
    _transport(480, "ASCENSOR", Color("#d4c8e5"))
    prompt.text = "PLANTA %d  |  E: escalera / ascensor" % current_floor

func _tile(rect: Rect2, tint: Color, title: String) -> void:
    var polygon := Polygon2D.new()
    polygon.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
    polygon.color = tint
    constructed.add_child(polygon)
    var label := Label.new()
    label.text = title
    label.position = rect.position + Vector2(16, 18)
    label.add_theme_color_override("font_color", Color("#26343c"))
    label.add_theme_font_size_override("font_size", 18)
    constructed.add_child(label)

func _outline(rect: Rect2, door: String) -> void:
    var l: float = rect.position.x
    var r: float = rect.end.x
    var t: float = rect.position.y
    var b: float = rect.end.y
    _edge(Vector2(l, t), Vector2(r, t), door == "top")
    _edge(Vector2(l, b), Vector2(r, b), door == "bottom")
    _edge(Vector2(l, t), Vector2(l, b), door == "left")
    _edge(Vector2(r, t), Vector2(r, b), door == "right")

func _edge(a: Vector2, b: Vector2, has_door: bool) -> void:
    if not has_door:
        _line(a, b)
        return
    var middle: Vector2 = (a + b) / 2.0
    var tangent: Vector2 = (b - a).normalized()
    _line(a, middle - tangent * 52.0)
    _line(middle + tangent * 52.0, b)

func _line(a: Vector2, b: Vector2, collision_enabled: bool = true) -> void:
    var ink := Line2D.new()
    ink.points = PackedVector2Array([a, b])
    ink.width = WALL
    ink.default_color = WALL_COLOR
    constructed.add_child(ink)
    if collision_enabled:
        var body := StaticBody2D.new()
        body.position = (a + b) / 2.0
        var shape := RectangleShape2D.new()
        shape.size = Vector2(absf(b.x-a.x)+WALL, absf(b.y-a.y)+WALL)
        var collider := CollisionShape2D.new()
        collider.shape = shape
        body.add_child(collider)
        constructed.add_child(body)

func _transport(x: float, name: String, color: Color) -> void:
    _tile(Rect2(x-64, 0, 128, 128), color, name)
