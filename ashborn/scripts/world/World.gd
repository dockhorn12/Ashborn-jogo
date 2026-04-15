extends Node2D

const ENEMY_CENA := preload("res://ashborn/scenes/enemies/Enemy.tscn")

const POSICOES_SPAWN := [
	Vector2(420, 200),
	Vector2(150, 150),
	Vector2(500, 380),
	Vector2(200, 380),
]

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var camera: Camera2D = $Player/Camera2D

var _inimigos_vivos: int = 0

func _ready() -> void:
	player.hp_changed.connect(hud.atualizar_hp)
	player.essencia_changed.connect(hud.atualizar_essencia)
	player.flechas_changed.connect(hud.atualizar_flechas)
	player.tomou_dano.connect(_screen_shake)

	for inimigo in get_tree().get_nodes_in_group("enemies"):
		_registrar_inimigo(inimigo)

func _registrar_inimigo(inimigo: Node) -> void:
	_inimigos_vivos += 1
	inimigo.morreu.connect(_on_inimigo_morreu)
	hud.atualizar_inimigos(_inimigos_vivos)

func _on_inimigo_morreu() -> void:
	_inimigos_vivos -= 1
	hud.atualizar_inimigos(_inimigos_vivos)
	if _inimigos_vivos <= 0:
		hud.mostrar_sala_limpa()
		await get_tree().create_timer(2.0).timeout
		_respawnar_inimigos()

func _respawnar_inimigos() -> void:
	for pos in POSICOES_SPAWN:
		var inimigo := ENEMY_CENA.instantiate()
		inimigo.add_to_group("enemies")
		add_child(inimigo)
		inimigo.global_position = pos
		_registrar_inimigo(inimigo)

# Balança a câmera ao tomar dano — efeito de impacto
func _screen_shake() -> void:
	var intensidade := 5.0
	var tween := create_tween()
	# Balança em 4 direções rapidamente
	tween.tween_property(camera, "offset", Vector2(intensidade, 0), 0.04)
	tween.tween_property(camera, "offset", Vector2(-intensidade, intensidade), 0.04)
	tween.tween_property(camera, "offset", Vector2(0, -intensidade), 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.04)
