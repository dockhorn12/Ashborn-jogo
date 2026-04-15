extends Node2D

# Cena do inimigo para respawn
const ENEMY_CENA := preload("res://ashborn/scenes/enemies/Enemy.tscn")

# Posições fixas onde os inimigos reaparecem
const POSICOES_SPAWN := [
	Vector2(420, 200),
	Vector2(150, 150),
	Vector2(500, 380),
	Vector2(200, 380),
]

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

# Quantos inimigos estão vivos na cena agora
var _inimigos_vivos: int = 0

func _ready() -> void:
	# Conecta sinais do player ao HUD
	player.hp_changed.connect(hud.atualizar_hp)
	player.essencia_changed.connect(hud.atualizar_essencia)

	# Registra os inimigos que já estão na cena
	# (get_nodes_in_group é seguro aqui pois filhos rodam _ready() antes do pai)
	for inimigo in get_tree().get_nodes_in_group("enemies"):
		_registrar_inimigo(inimigo)

# Conecta o sinal de morte de um inimigo e incrementa o contador
func _registrar_inimigo(inimigo: Node) -> void:
	_inimigos_vivos += 1
	inimigo.morreu.connect(_on_inimigo_morreu)
	hud.atualizar_inimigos(_inimigos_vivos)

func _on_inimigo_morreu() -> void:
	_inimigos_vivos -= 1
	hud.atualizar_inimigos(_inimigos_vivos)

	# Quando todos morrerem, aguarda 2s e respawna
	if _inimigos_vivos <= 0:
		hud.mostrar_sala_limpa()
		await get_tree().create_timer(2.0).timeout
		_respawnar_inimigos()

func _respawnar_inimigos() -> void:
	# Cria um inimigo em cada posição fixa e os registra
	for pos in POSICOES_SPAWN:
		var inimigo := ENEMY_CENA.instantiate()
		inimigo.add_to_group("enemies")
		add_child(inimigo)
		inimigo.global_position = pos
		_registrar_inimigo(inimigo)
