extends Area2D

# Visual da essência
@onready var visual: ColorRect = $Visual

func _ready() -> void:
	# Conecta o sinal: quando o player encostar, coleta a essência
	body_entered.connect(_on_body_entered)
	# Pequena animação de pulso ao aparecer
	_animar_surgimento()

func _on_body_entered(body: Node2D) -> void:
	# Só coleta se for o player
	if not body.has_method("coletar_essencia"):
		return
	body.coletar_essencia()
	_animar_coleta()

func _animar_surgimento() -> void:
	# Começa pequeno e cresce até o tamanho normal
	visual.scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animar_coleta() -> void:
	# Desativa a colisão imediatamente para não coletar duas vezes
	$CollisionShape2D.set_deferred("disabled", true)
	# Cresce e some rapidamente
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector2(2.0, 2.0), 0.2)
	tween.tween_property(visual, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
