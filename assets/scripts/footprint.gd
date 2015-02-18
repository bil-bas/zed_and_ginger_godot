extends Quad

var material

func _ready():
    material = FixedMaterial.new()
    set_material_override(material)

func set_color(color):
    material.set_parameter(FixedMaterial.PARAM_DIFFUSE, color)

func _on_Timer_timeout():
    queue_free()