extends CharacterBody2D

signal morreu

const ESSENCIA_CENA    := preload("res://ashborn/scenes/pickups/Essence.tscn")
const POCAO_CENA       := preload("res://ashborn/scenes/pickups/HealthPotion.tscn")
const FLECHA_CENA      := preload("res://ashborn/scenes/pickups/ArrowPickup.tscn")

@export var enemy_name: String = "Inimigo"
@export var max_hp: int = 30
@export var dano_contato: int = 10
@export var move_speed: float = 60.0

var current_hp: int

@onready var visual: ColorRect = $Visual
@onready var contact_area: Area2D = $ContactArea

const COR_NORMAL := Color(0.65, 0.05, 0.05, 1)
const COR_DANO   := Color(1.0, 0.9, 0.2, 1)

var _player: Node2D = null
var _altar: Node2D = null

# Raio de evasão do altar
const RAIO_ALTAR: float = 65.0

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	_altar  = get_tree().get_first_node_in_group("altar")
	_criar_luz()

func _physics_process(_delta: float) -> void:
	if _player and is_instance_valid(_player):
		var direcao := (_player.global_position - global_position).normalized()
		velocity = direcao * move_speed

		# Desvia do altar se estiver muito perto
		if _altar and is_instance_valid(_altar):
			var dist_altar := global_position.distance_to(_altar.global_position)
			if dist_altar < RAIO_ALTAR:
				var fuga := (global_position - _altar.global_position).normalized()
				velocity += fuga * move_speed * 2.5

		move_and_slide()

	for body in contact_area.get_overlapping_bodies():
		if body.has_method("receber_dano_contato"):
			body.receber_dano_contato(dano_contato, global_position)

func receber_dano(quantidade: int) -> void:
	current_hp -= quantidade
	print("%s recebeu %d de dano — HP: %d/%d" % [enemy_name, quantidade, current_hp, max_hp])
	_piscar()
	if current_hp <= 0:
		_morrer()

func _piscar() -> void:
	visual.color = COR_DANO
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		visual.color = COR_NORMAL

func _morrer() -> void:
	print(enemy_name + " morreu!")
	morreu.emit()
	_dropar_essencia()
	_dropar_itens()
	queue_free()

func _dropar_essencia() -> void:
	var essencia := ESSENCIA_CENA.instantiate()
	essencia.global_position = global_position
	get_parent().add_child(essencia)

func _dropar_itens() -> void:
	# 50% de chance: poção de vida
	if randf() < 0.5:
		var pocao := POCAO_CENA.instantiate()
		pocao.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		get_parent().add_child(pocao)

	# 50% de chance: pacote de flechas
	if randf() < 0.5:
		var flechas := FLECHA_CENA.instantiate()
		flechas.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		get_parent().add_child(flechas)

# Luz vermelha fraca para atmosfera
func _criar_luz() -> void:
	var luz := PointLight2D.new()
	luz.energy = 0.6
	luz.texture_scale = 1.2
	luz.color = Color(0.8, 0.1, 0.1, 1)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.width = 128
	tex.height = 128
	luz.texture = tex
	add_child(luz)
