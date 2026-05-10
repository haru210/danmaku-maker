# Boss.gd
extends Area2D

var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.show_behind_parent = true # 親の _draw を前面に表示
	add_child(sprite)
	
	# Globalから設定を取得
	var settings = Global.config_data.get("settings", {}).get("boss", {})
	var tex_key = settings.get("texture", "")
	if Global.textures.has(tex_key):
		sprite.texture = Global.textures[tex_key]
	
	# スケール設定
	var sc = settings.get("scale", [1.0, 1.0])
	sprite.scale = Vector2(sc[0], sc[1])
	
	# 当たり判定の設定
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = settings.get("collision_radius", 30.0)
	collision_shape.shape = circle
	add_child(collision_shape)
	
	# レイヤー設定 (Layer 2: Boss, Mask 1: Player, Mask 8: PlayerBullets)
	collision_layer = 2
	collision_mask = 1 | 8
	
	# 初期位置
	var pos = settings.get("initial_position", [576, 150])
	position = Vector2(pos[0], pos[1])

	# 衝突イベントの接続
	area_entered.connect(_on_area_entered)
	
	queue_redraw()

func _draw() -> void:
	# デバッグ用：当たり判定の円を描画
	var radius = 30.0
	var settings = Global.config_data.get("settings", {}).get("boss", {})
	radius = settings.get("collision_radius", 30.0)
	# 線を太く (4.0) し、色を鮮やかに
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(1.0, 0.2, 0.2, 1.0), 4.0)

func _on_area_entered(area: Area2D) -> void:
	print("Boss collided with: ", area.name)
