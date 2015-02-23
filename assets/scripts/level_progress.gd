extends Range

const MARGIN = 2
const END_OFFSET = 30

var player_sprite
var x = 0
var background = Color(0, 0, 0, 1)
var bar = Color(255, 255, 255, 1)


func _ready():
    player_sprite = get_node(@'PlayerSprite')
    set_process(true)

func _process(delta):
    x = ((get_value() - get_min()) / (get_max() - get_min())) * (get_size().x - (END_OFFSET + MARGIN * 2)) + END_OFFSET + MARGIN
    player_sprite.set_pos(Vector2(x, 0))
    update()

func _draw():
    var width = get_size().width
    var height = get_size().height
    draw_rect(Rect2(0, 0, width, height), background)
    draw_rect(Rect2(MARGIN, MARGIN, x, height - MARGIN * 2), bar)
