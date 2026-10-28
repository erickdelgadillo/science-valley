extends Node2D
## Modular research building. Original lab.tscn and artwork remain untouched.
const WALL_THICKNESS := 12.0
const HALL_COLOR := Color("#dddcd7")
const ROOMS_0 := [
    {"label":"LABORATORIO HÚMEDO","rect":Rect2(0,0,1152,640),"color":Color("#b9ddd4"),"door":"bottom","lab":true},
    {"label":"SIN ASIGNAR 1","rect":Rect2(0,736,480,288),"color":Color("#eeeae2"),"door":"right","lab":false},
    {"label":"SIN ASIGNAR 2","rect":Rect2(672,736,480,288),"color":Color("#eeeae2"),"door":"left","lab":false},
    {"label":"SIN ASIGNAR 3","rect":Rect2(0,1024,480,416),"color":Color("#eeeae2"),"door":"right","lab":false},
    {"label":"SIN ASIGNAR 4","rect":Rect2(672,1024,480,416),"color":Color("#eeeae2"),"door":"left","lab":false}
]
const ROOMS_1 := [
    {"label":"LABORATORIO GENERAL","rect":Rect2(0,0,576,640),"color":Color("#d6e9cb"),"door":"bottom","lab":true},
    {"label":"EXTRACCIÓN DE ADN","rect":Rect2(576,0,576,640),"color":Color("#ccd6f1"),"door":"bottom","lab":true},
    {"label":"REACTIVOS Y CONSUMIBLES","rect":Rect2(0,736,240,480),"color":Color("#e4d5ea"),"door":"top","lab":false},
    {"label":"ULTRACONGELADORES","rect":Rect2(240,736,240,480),"color":Color("#cbdcf0"),"door":"top","lab":false},
    {"label":"ALMACÉN DE CAMPO","rect":Rect2(672,736,480,288),"color":Color("#c8dcda"),"door":"left","lab":false},
    {"label":"BAÑO UNISEX","rect":Rect2(672,1024,480,144),"color":Color("#e5dbed"),"door":"left","lab":false},
    {"label":"SIN ASIGNAR","rect":Rect2(672,1168,480,144),"color":Color("#eeeae2"),"door":"left","lab":false},
    {"label":"DESPACHO DEL DIRECTOR","rect":Rect2(0,1216,480,224),"color":Color("#ead4c1"),"door":"right","lab":false},
    {"label":"MI DESPACHO","rect":Rect2(672,1216,480,224),"color":Color("#f0ddbd"),"door":"left","lab":false}
]
var current_floor: int = 0
var layout_root: Node2D
var status_label: Label
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
    layout_root = Node2D.new()
    layout_root.name = "Architecture"
    add_child(layout_root)
    status_label = Label.new()
    status_label.position = Vector2(-40,-115)
    status_label.add_theme_color_override("font_color",Color("#26343c"))
    status_label.add_theme_font_size_override("font_size",18)
    player.add_child(status_label)
    _build_floor()
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
    current_floor = 1 - current_floor
    # Arrive beside the transport used, not in an unrelated room.
    player.position = Vector2(1057 if using_elevator else 95,688)
    _build_floor()
    _update_outfit()

func _update_outfit() -> void:
    var inside_lab := false
    var rooms: Array = ROOMS_0 if current_floor == 0 else ROOMS_1
    for room in rooms:
        if room["lab"] and room["rect"].has_point(player.position):
            inside_lab = true
            break
    player.set_lab_outfit(inside_lab)

func _build_floor() -> void:
    for item in layout_root.get_children():
        layout_root.remove_child(item)
        item.queue_free()
    _paint(Rect2(0,640,1152,96),HALL_COLOR,"DISTRIBUIDOR")
    _paint(Rect2(480,736,192,704),HALL_COLOR,"PASILLO")
    var rooms: Array = ROOMS_0 if current_floor == 0 else ROOMS_1
    for room in rooms:
        _paint(room["rect"],room["color"],room["label"])
        _outline(room["rect"],room["door"])
    # Top facade and distributor exits are bounded by the room edges.
    # Side corridor walls have openings facing each room, generated from room boundaries.
    if current_floor == 0:
        _paint(Rect2(0,1440,1152,640),Color("#acd3a5"),"PATIO EXTERIOR")
        _segment(Vector2(0,1440),Vector2(520,1440))
        _segment(Vector2(632,1440),Vector2(1152,1440))
        _segment(Vector2(0,1440),Vector2(0,2080))
        _segment(Vector2(1152,1440),Vector2(1152,2080))
        _segment(Vector2(0,2080),Vector2(1152,2080))
    else:
        _segment(Vector2(480,1440),Vector2(672,1440))
    _paint(Rect2(32,648,126,80),Color("#bfd3e8"),"ESCALERA [E]")
    _paint(Rect2(994,648,126,80),Color("#d4c8e5"),"ASCENSOR [E]")
    # Open intersection between the transversal distributor and main corridor.
    _segment(Vector2(480,736),Vector2(480,1216),false)
    _segment(Vector2(672,736),Vector2(672,1440),false)

func _paint(rect: Rect2,tint: Color,name: String) -> void:
    var shape := Polygon2D.new()
    shape.polygon = PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
    shape.color = tint
    layout_root.add_child(shape)
    var title := Label.new()
    title.text = name
    title.position = rect.position + Vector2(14,16)
    title.add_theme_color_override("font_color",Color("#26343c"))
    title.add_theme_font_size_override("font_size",19)
    layout_root.add_child(title)

func _outline(rect: Rect2,door: String) -> void:
    var a: Vector2 = rect.position
    var b: Vector2 = rect.end
    _edge(a,Vector2(b.x,a.y),door == "top")
    _edge(Vector2(a.x,b.y),b,door == "bottom")
    _edge(a,Vector2(a.x,b.y),door == "left")
    _edge(Vector2(b.x,a.y),b,door == "right")

func _edge(start: Vector2,end: Vector2,opening: bool) -> void:
    if not opening:
        _segment(start,end)
        return
    var mid := (start+end)*0.5
    var tangent := (end-start).normalized()
    _segment(start,mid-tangent*56.0)
    _segment(mid+tangent*56.0,end)

func _segment(start: Vector2,end: Vector2,collide: bool = true) -> void:
    var line := Line2D.new()
    line.points = PackedVector2Array([start,end])
    line.width = WALL_THICKNESS
    line.default_color = Color("#45545c")
    line.z_index = 2
    layout_root.add_child(line)
    if collide:
        var wall := StaticBody2D.new()
        wall.collision_layer = 1
        wall.position = (start+end)*0.5
        var hit := CollisionShape2D.new()
        var box := RectangleShape2D.new()
        box.size = Vector2(absf(end.x-start.x)+WALL_THICKNESS,absf(end.y-start.y)+WALL_THICKNESS)
        hit.shape = box
        wall.add_child(hit)
        layout_root.add_child(wall)
