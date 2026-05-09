# Player.gd
extends Area2D

var speed: float = 400.0
var sprite: Sprite2D

func _ready() -> void:
	# 子ノードとしてSprite2Dを作成
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# Globalから設定を取得
	var settings = Global.config_data.get("settings", {}).get("player", {})
	var tex_key = settings.get("texture", "")
	if Global.textures.has(tex_key):
		sprite.texture = Global.textures[tex_key]
	
	speed = settings.get("speed", 400.0)
	
	# 初期位置
	var pos = settings.get("initial_position", [576, 600])
	position = Vector2(pos[0], pos[1])

func _physics_process(delta: float) -> void:
	# 入力による移動
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += direction * speed * delta
	
	# 画面外制限
	var game_size = Global.get_game_size()
	position = position.clamp(Vector2.ZERO, game_size)
