extends Area2D

# Velocidade de deslocamento do projétil
const VELOCIDADE: float = 400.0

# Dano causado ao acertar um inimigo
const DANO: int = 25

# Tempo de vida máximo em segundos (some se não acertar nada)
const TEMPO_VIDA: float = 1.5

# Direção definida pelo Player ao instanciar
var direcao: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Conecta colisão com inimigos
	body_entered.connect(_on_body_entered)
	# Destrói o projétil após o tempo de vida
	get_tree().create_timer(TEMPO_VIDA).timeout.connect(queue_free)
	# Aponta visualmente na direção do disparo
	rotation = direcao.angle()

func _process(delta: float) -> void:
	# Move o projétil em linha reta
	global_position += direcao * VELOCIDADE * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("receber_dano"):
		body.receber_dano(DANO)
	# Pequeno flash ao impactar e some
	_explodir()

func _explodir() -> void:
	# Desativa colisão para não acertar mais nada
	$CollisionShape2D.set_deferred("disabled", true)
	# Expande e some
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Visual, "scale", Vector2(3.0, 3.0), 0.15)
	tween.tween_property($Visual, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(queue_free)
