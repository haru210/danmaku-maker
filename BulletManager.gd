# BulletManager.gd
extends Node2D

# 弾のデータを保持するクラス（後でパフォーマンス最適化のために構造化する準備）
class Bullet:
	var sprite: Sprite2D
	var position: Vector2
	var velocity: Vector2
	var radius: float
	
	func _init(s: Sprite2D, p: Vector2, v: Vector2, r: float):
		sprite = s
		position = p
		velocity = v
		radius = r
		sprite.position = p

var active_bullets: Array[Bullet] = []
var player: Node2D
var player_radius: float = 0.0

func _ready() -> void:
	# プレイヤーの参照を取得
	player = get_parent().get_node_or_null("Player")
	
	# プレイヤーの半径をキャッシュ
	var player_settings = Global.config_data.get("settings", {}).get("player", {})
	player_radius = player_settings.get("collision_radius", 5.0)

func _process(delta: float) -> void:
	var game_size = Global.get_game_size()
	var margin = 50.0 # 画面外に少し出てから消去
	
	var player_pos = Vector2.ZERO
	if player:
		player_pos = player.position
	
	var i = active_bullets.size() - 1
	while i >= 0:
		var b = active_bullets[i]
		
		# 移動
		b.position += b.velocity * delta
		b.sprite.position = b.position
		
		# 当たり判定 (プレイヤーとの距離チェック)
		if player:
			var dist_sq = b.position.distance_squared_to(player_pos)
			var radius_sum = b.radius + player_radius
			if dist_sq < radius_sum * radius_sum:
				# 衝突
				if player.has_method("take_damage"):
					player.take_damage()
				
				# 弾を消去
				b.sprite.queue_free()
				active_bullets.remove_at(i)
				i -= 1
				continue
		
		# 画面外判定（簡易）
		if b.position.x < -margin or b.position.x > game_size.x + margin or \
		   b.position.y < -margin or b.position.y > game_size.y + margin:
			b.sprite.queue_free()
			active_bullets.remove_at(i)
		
		i -= 1

func handle_event(event: Dictionary) -> void:
	var type = event.get("type", "")
	
	match type:
		"independent":
			# 単発の弾を生成
			spawn_bullet(event.get("params", {}))
		"pattern":
			# パターン（今後実装予定）
			pass

func spawn_bullet(params: Dictionary) -> void:
	var tex_key = params.get("texture", "")
	if not Global.textures.has(tex_key):
		printerr("Bullet Error: Texture not found: ", tex_key)
		return
	
	var sprite = Sprite2D.new()
	sprite.texture = Global.textures[tex_key]
	
	# サイズ（スケール）
	var sc = params.get("scale", [1.0, 1.0])
	sprite.scale = Vector2(sc[0], sc[1])
	
	# 当たり判定の半径
	# params から優先的に取得し、なければデフォルト値を使用
	var radius = params.get("collision_radius", 4.0)
	
	# 座標
	var pos_arr = params.get("position", [0, 0])
	var pos = Vector2(pos_arr[0], pos_arr[1])
	
	# 速度と方向
	var speed = params.get("speed", 200.0)
	var angle_deg = calculate_angle(params, pos)
	var velocity = Vector2.RIGHT.rotated(deg_to_rad(angle_deg)) * speed
	
	var bullet = Bullet.new(sprite, pos, velocity, radius)
	add_child(sprite)
	active_bullets.append(bullet)

func calculate_angle(params: Dictionary, spawn_pos: Vector2) -> float:
	var dir_type = params.get("direction_type", "fixed")
	var base_angle = params.get("angle", 90.0)
	var final_base = base_angle
	
	match dir_type:
		"aim":
			if player:
				var to_player = player.position - spawn_pos
				final_base = rad_to_deg(to_player.angle()) + params.get("aim_offset", 0.0)
		"fixed":
			final_base = base_angle
	
	# ランダムな振れ幅を適用
	var rand_range = params.get("random_range", 0.0)
	if rand_range > 0:
		final_base += randf_range(-rand_range / 2.0, rand_range / 2.0)
	
	return final_base
