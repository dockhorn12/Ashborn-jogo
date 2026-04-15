extends Area2D

@onready var visual: ColorRect = $Visual

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_animar_surgimento()

func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("curar"):
		return
	body.curar(body.max_hp * 0.25)
	_animar_coleta()

func _animar_surgimento() -> void:
	visual.scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animar_coleta() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector2(2.5, 2.5), 0.2)
	tween.tween_property(visual, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
