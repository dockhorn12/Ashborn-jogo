extends CanvasLayer

# Referências aos nós visuais
@onready var barra_fill: ColorRect = $Control/BarraHP/Fill
@onready var label_hp: Label = $Control/LabelHP

# Largura máxima da barra (em pixels)
const LARGURA_MAX: float = 200.0

# Atualiza a barra com os valores atuais de HP
func atualizar_hp(atual: int, maximo: int) -> void:
	var proporcao := float(atual) / float(maximo)
	barra_fill.size.x = LARGURA_MAX * proporcao
	label_hp.text = "HP: %d / %d" % [atual, maximo]
