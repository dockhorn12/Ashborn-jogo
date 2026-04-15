extends CharacterBody2D

# Emitido sempre que o HP muda — o HUD escuta este sinal
signal hp_changed(atual: int, maximo: int)

# --- Stats do Kael ---
var move_speed: float = 150.0
var max_hp: int = 100
var current_hp: int = 100

# Dano causado por cada ataque
const DANO_ATAQUE: int = 10

# Tempo de invulnerabilidade após receber dano (segundos)
const TEMPO_INVULNERAVEL: float = 0.5

# Controle de estado
var _invulneravel: bool = false
var _morto: bool = false

# Guarda a última direção para orientar a hitbox
var last_direction: Vector2 = Vector2.RIGHT

# Velocidade do knockback ao tomar dano
var _knockback: Vector2 = Vector2.ZERO

# Controle de multi-hit por ataque
var _inimigos_atingidos: Array = []

# --- Referências ---
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var visual: ColorRect = $Visual

# Cores
const COR_NORMAL     := Color(0.2, 0.6, 1.0, 1)
const COR_DANO       := Color(1.0, 1.0, 1.0, 1)
const COR_MORTO      := Color(0.25, 0.25, 0.25, 1)
const COR_SANGUE     := Color(0.75, 0.0, 0.05, 1)

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_hp = max_hp
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	# Adiciona ao grupo para que inimigos possam encontrar o player
	add_to_group("player")
	# Emite o HP inicial para o HUD exibir corretamente desde o começo
	hp_changed.emit(current_hp, max_hp)

func _physics_process(delta: float) -> void:
	var _delta := delta
	# Para todo movimento ao morrer
	if _morto:
		velocity = Vector2.ZERO
		return

	# Aplica knockback e amorece a cada frame
	if _knockback != Vector2.ZERO:
		_knockback = _knockback.move_toward(Vector2.ZERO, 400.0 * _delta)

	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = direction * move_speed + _knockback
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if _morto:
		return
	if event.is_action_pressed("attack"):
		_executar_ataque()

func _executar_ataque() -> void:
	_inimigos_atingidos.clear()
	attack_hitbox.position = last_direction.normalized() * 28.0
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack_hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body in _inimigos_atingidos:
		return
	_inimigos_atingidos.append(body)
	if body.has_method("receber_dano"):
		body.receber_dano(DANO_ATAQUE)

# Chamado pelo inimigo ao encostar no player; origem é a posição do inimigo
func receber_dano_contato(quantidade: int, origem: Vector2 = Vector2.ZERO) -> void:
	if _morto or _invulneravel:
		return

	current_hp -= quantidade
	print("Kael recebeu %d de dano — HP: %d/%d" % [quantidade, current_hp, max_hp])

	# Knockback: empurra Kael para longe do inimigo
	var direcao_knockback := (global_position - origem).normalized()
	_knockback = direcao_knockback * 220.0

	# Notifica o HUD com o novo valor de HP
	hp_changed.emit(current_hp, max_hp)

	_spawnar_sangue()
	_piscar()
	_ativar_invulnerabilidade()

	if current_hp <= 0:
		_morrer()

func _spawnar_sangue() -> void:
	# Cria 6 gotas vermelhas que caem e somem em 0.35 segundos
	for i in range(6):
		var gota := ColorRect.new()
		gota.size = Vector2(4, 6)
		gota.color = COR_SANGUE

		# Posição inicial: espalhada ao redor do Kael
		var offset := Vector2(randf_range(-10, 10), randf_range(-10, 6))
		gota.global_position = global_position + offset

		# Adiciona a gota como filho da cena (não do player, para não mover junto)
		get_parent().add_child(gota)

		# Anima: cai para baixo e some
		var tween := get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(gota, "global_position:y", gota.global_position.y + 22, 0.35)
		tween.tween_property(gota, "modulate:a", 0.0, 0.35)
		tween.chain().tween_callback(gota.queue_free)

func _piscar() -> void:
	visual.color = COR_DANO
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self) and not _morto:
		visual.color = COR_NORMAL

func _ativar_invulnerabilidade() -> void:
	_invulneravel = true
	await get_tree().create_timer(TEMPO_INVULNERAVEL).timeout
	if is_instance_valid(self):
		_invulneravel = false

func _morrer() -> void:
	_morto = true
	# Muda a cor para cinza escuro — Kael "apagado"
	visual.color = COR_MORTO
	# Spawna uma última leva de sangue maior
	for i in range(3):
		_spawnar_sangue()
	print("Kael morreu!")
	# Recarrega a cena após 1.5 segundos
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
