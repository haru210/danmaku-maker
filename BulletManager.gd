# BulletManager.gd
extends Node2D

# 弾のデータを保持するクラス（後でパフォーマンス最適化のために構造化する準備）
class Bullet:
	var sprite: Sprite2D
	var position: Vector2
	var velocity: Vector2
	
	func _init(s: Sprite2D, p: Vector2, v: Vector2):
		sprite = s
		position = p
		velocity = v
		sprite.position = p

var active_bullets: Array[Bullet] = []

func _process(delta: float) -> void:
	var game_size = Global.get_game_size()
	var margin = 50.0 # 画面外に少し出てから消去
	
	var i = active_bullets.size() - 1
	while i >= 0:
		var b = active_bullets[i]
		
		# 移動
		b.position += b.velocity * delta
		b.sprite.position = b.position
		
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
	
	# 座標
	var pos_arr = params.get("position", [0, 0])
	var pos = Vector2(pos_arr[0], pos_arr[1])
	
	# 速度と方向
	var speed = params.get("speed", 200.0)
	var angle_deg = params.get("angle", 90.0) # デフォルトは下向き
	var velocity = Vector2.RIGHT.rotated(deg_to_rad(angle_deg)) * speed
	
	var bullet = Bullet.new(sprite, pos, velocity)
	add_child(sprite)
	active_bullets.append(bullet)
