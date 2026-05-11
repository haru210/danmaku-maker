# Player.gd
extends Area2D

var speed: float = 400.0
var sprite: Sprite2D

func _ready() -> void:
	# 子ノードとしてSprite2Dを作成
	sprite = Sprite2D.new()
	sprite.show_behind_parent = true # 親の _draw を前面に表示するために必要
	add_child(sprite)
	
	# Globalから設定を取得
	var settings = Global.config_data.get("settings", {}).get("player", {})
	var tex_key = settings.get("texture", "")
	if Global.textures.has(tex_key):
		sprite.texture = Global.textures[tex_key]
	
	speed = settings.get("speed", 400.0)
	
	# スケール設定
	var sc = settings.get("scale", [1.0, 1.0])
	sprite.scale = Vector2(sc[0], sc[1])
	
	# 当たり判定の設定
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = settings.get("collision_radius", 5.0)
	collision_shape.shape = circle
	add_child(collision_shape)
	
	# レイヤー設定 (Layer 1: Player, Mask 2: Boss, Mask 4: EnemyBullets)
	collision_layer = 1
	collision_mask = 2 | 4
	
	# 初期位置
	var pos = settings.get("initial_position", [576, 600])
	position = Vector2(pos[0], pos[1])

	# 衝突イベントの接続
	area_entered.connect(_on_area_entered)
	
	queue_redraw()

func _draw() -> void:
	# デバッグ用：当たり判定の円を描画
	var radius = 5.0
	var settings = Global.config_data.get("settings", {}).get("player", {})
	radius = settings.get("collision_radius", 5.0)
	# 線を太く (4.0) し、色をより鮮やかに
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(0.2, 1.0, 0.2, 1.0), 4.0)

func _on_area_entered(area: Area2D) -> void:
	print("Player collided with: ", area.name)
	take_damage()

func take_damage() -> void:
	# とりあえずログ出力のみ。将来的にHP減少や無敵時間などを実装する。
	print("!!! PLAYER HIT !!!")

func _physics_process(delta: float) -> void:
	# 入力による移動
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += direction * speed * delta
	
	# 画面外制限
	var game_size = Global.get_game_size()
	position = position.clamp(Vector2.ZERO, game_size)
