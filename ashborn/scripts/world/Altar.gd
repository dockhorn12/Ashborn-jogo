extends Area2D

# HP curado por segundo enquanto o player está no altar
const CURA_POR_SEGUNDO: float = 12.0

# Raio em pixels que os inimigos devem evitar
const RAIO_REPULSAO: float = 65.0

func _ready() -> void:
	add_to_group("altar")
	_criar_luz()

func _physics_process(delta: float) -> void:
	# Cura o player se estiver dentro do altar
	for body in get_overlapping_bodies():
		if body.has_method("curar"):
			body.curar(CURA_POR_SEGUNDO * delta)

# Cria uma PointLight2D dourada gerada por código
func _criar_luz() -> void:
	var luz := PointLight2D.new()
	luz.energy = 1.4
	luz.texture_scale = 3.0
	luz.color = Color(0.95, 0.85, 0.2, 1)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.width = 128
	tex.height = 128
	luz.texture = tex
	add_child(luz)
