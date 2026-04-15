extends CharacterBody2D

# Emitido sempre que o HP muda — o HUD escuta este sinal
signal hp_changed(atual: int, maximo: int)

# Emitido ao coletar essência
signal essencia_changed(total: int)

# Emitido ao tomar dano — a câmera escuta para fazer screen shake
signal tomou_dano

# --- Stats do Kael ---
var move_speed: float = 160.0
var max_hp: int = 100
var current_hp: int = 100

# Total de essência coletada
var essencia: int = 0

# Dano do ataque corpo a corpo
const DANO_ATAQUE: int = 15

# Custo de essência para usar a skill Q
const CUSTO_SKILL: int = 10

# Tempo de invulnerabilidade após receber dano (segundos)
const TEMPO_INVULNERAVEL: float = 0.5

# Cooldown do dash em segundos
const COOLDOWN_DASH: float = 0.8

# Controle de estado
var _invulneravel: bool = false
var _morto: bool = false
var _dash_pronto: bool = true

# Direção atual do mouse em relação ao player
var _direcao_mouse: Vector2 = Vector2.RIGHT

# Velocidade do knockback ao tomar dano
var _knockback: Vector2 = Vector2.ZERO

# Controle de multi-hit por ataque
var _inimigos_atingidos: Array = []

# Cena do projétil da skill Q
const PROJECTILE_CENA := preload("res://ashborn/scenes/combat/Projectile.tscn")

# --- Referências ---
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var visual: ColorRect = $Visual
@onready var camera: Camera2D = $Camera2D

# Cores
const COR_NORMAL     := Color(0.35, 0.75, 1.0, 1)
const COR_DANO       := Color(1.0, 1.0, 1.0, 1)
const COR_MORTO      := Color(0.25, 0.25, 0.25, 1)
const COR_SANGUE     := Color(0.75, 0.0, 0.05, 1)

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_hp = max_hp
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	add_to_group("player")
	hp_changed.emit(current_hp, max_hp)
	essencia_changed.emit(essencia)

func _physics_process(delta: float) -> void:
	if _morto:
		velocity = Vector2.ZERO
		return

	# Atualiza direção para o mouse a cada frame
	_direcao_mouse = (get_global_mouse_position() - global_position).normalized()

	# Aplica knockback e amorece gradualmente
	if _knockback != Vector2.ZERO:
		_knockback = _knockback.move_toward(Vector2.ZERO, 500.0 * delta)

	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * move_speed + _knockback
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if _morto:
		return
	if event.is_action_pressed("attack"):
		_executar_ataque()
	if event.is_action_pressed("skill_q"):
		_executar_skill_q()
	if event.is_action_pressed("dash"):
		_executar_dash()

# Ataque corpo a corpo na direção do mouse
func _executar_ataque() -> void:
	_inimigos_atingidos.clear()
	attack_hitbox.position = _direcao_mouse * 28.0
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	attack_hitbox.monitoring = false

# Skill Q — dispara projétil na direção do mouse (custa 10 de essência)
func _executar_skill_q() -> void:
	if essencia < CUSTO_SKILL:
		print("Essência insuficiente para usar skill!")
		return
	essencia -= CUSTO_SKILL
	essencia_changed.emit(essencia)

	var proj := PROJECTILE_CENA.instantiate()
	proj.direcao = _direcao_mouse
	proj.global_position = global_position + _direcao_mouse * 20.0
	get_parent().add_child(proj)

# Dash rápido na direção do movimento (ou do mouse se parado)
func _executar_dash() -> void:
	if not _dash_pronto or _morto:
		return
	_dash_pronto = false
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		dir = _direcao_mouse
	# Aplica impulso forte brevemente
	_knockback = dir * 420.0
	# Fica semi-transparente durante o dash
	visual.modulate = Color(1, 1, 1, 0.4)
	await get_tree().create_timer(0.15).timeout
	visual.modulate = Color(1, 1, 1, 1.0)
	# Aguarda cooldown antes de liberar novo dash
	await get_tree().create_timer(COOLDOWN_DASH).timeout
	if is_instance_valid(self):
		_dash_pronto = true

# Chamado pela Essence ao ser coletada
func coletar_essencia() -> void:
	essencia += 1
	essencia_changed.emit(essencia)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body in _inimigos_atingidos:
		return
	_inimigos_atingidos.append(body)
	if body.has_method("receber_dano"):
		body.receber_dano(DANO_ATAQUE)

# Chamado pelo inimigo ao encostar no player
func receber_dano_contato(quantidade: int, origem: Vector2 = Vector2.ZERO) -> void:
	if _morto or _invulneravel:
		return

	current_hp -= quantidade
	print("Kael recebeu %d de dano — HP: %d/%d" % [quantidade, current_hp, max_hp])

	var direcao_knockback := (global_position - origem).normalized()
	_knockback = direcao_knockback * 240.0

	hp_changed.emit(current_hp, max_hp)
	tomou_dano.emit()

	_spawnar_sangue()
	_piscar()
	_ativar_invulnerabilidade()

	if current_hp <= 0:
		_morrer()

func _spawnar_sangue() -> void:
	for i in range(6):
		var gota := ColorRect.new()
		gota.size = Vector2(4, 6)
		gota.color = COR_SANGUE
		var offset := Vector2(randf_range(-12, 12), randf_range(-12, 8))
		gota.global_position = global_position + offset
		get_parent().add_child(gota)
		var tween := get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(gota, "global_position:y", gota.global_position.y + 26, 0.4)
		tween.tween_property(gota, "modulate:a", 0.0, 0.4)
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
	visual.color = COR_MORTO
	for i in range(4):
		_spawnar_sangue()
	print("Kael morreu!")
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
