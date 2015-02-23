extends Range

const MARGIN = 2
const END_OFFSET = 30

var player_sprite
var x = 0
var background = Color(0, 0, 0, 1)
var move_bar = Color(255, 255, 255, 1)
var chase_bar = Color(255, 0, 0, 1)

var chase_x = 0 setget set_chase_x
func set_chase_x(value):
    chase_x = value

func _ready():
    player_sprite = get_node(@'PlayerSprite')
    set_process(true)

func world_x_to_bar_x(x):
	return ((x - get_min()) / (get_max() - get_min())) * (get_size().x - (END_OFFSET + MARGIN * 2)) + END_OFFSET + MARGIN

func _process(delta):
    x = world_x_to_bar_x(get_value())
    player_sprite.set_pos(Vector2(x, 0))
    update()

func _draw():
    var width = get_size().width
    var height = get_size().height
    draw_rect(Rect2(0, 0, width, height), background)
    draw_rect(Rect2(MARGIN, MARGIN, x, height - MARGIN * 2), move_bar)
    draw_rect(Rect2(MARGIN, MARGIN * 2, world_x_to_bar_x(chase_x), height - MARGIN * 4), chase_bar)
