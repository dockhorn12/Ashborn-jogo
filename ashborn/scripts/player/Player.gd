extends CharacterBody2D

# --- Stats do Kael ---
var move_speed: float = 150.0
var max_hp: int = 100
var current_hp: int = 100

# Dano causado por cada ataque
const DANO_ATAQUE: int = 10

# Guarda a última direção do movimento para orientar a hitbox de ataque
var last_direction: Vector2 = Vector2.RIGHT

# Controle de multi-hit: guarda os inimigos já atingidos neste ataque
var _inimigos_atingidos: Array = []

@onready var attack_hitbox: Area2D = $AttackHitbox

func _ready() -> void:
	# Top-down: sem gravidade nem snap de chão
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Hitbox começa desativada — só liga durante o ataque
	attack_hitbox.monitoring = false

	# Conecta o sinal: quando a hitbox tocar um corpo, chama _on_hitbox_body_entered
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Atualiza a última direção só quando o player estiver se movendo
	if direction != Vector2.ZERO:
		last_direction = direction

	velocity = direction * move_speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Detecta o botão de ataque (tecla F)
	if event.is_action_pressed("attack"):
		_executar_ataque()

func _executar_ataque() -> void:
	# Limpa a lista de inimigos atingidos do ataque anterior
	_inimigos_atingidos.clear()

	# Posiciona a hitbox 36px na frente do player (direção que ele está olhando)
	attack_hitbox.position = last_direction.normalized() * 36.0

	# Liga a hitbox por 0.15 segundos e desliga em seguida
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack_hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Ignora se esse inimigo já foi atingido neste ataque (evita multi-hit)
	if body in _inimigos_atingidos:
		return

	# Registra o inimigo como atingido neste ataque
	_inimigos_atingidos.append(body)

	# Chama receber_dano passando o valor de dano do Kael
	if body.has_method("receber_dano"):
		body.receber_dano(DANO_ATAQUE)
