# Boss.gd
extends Area2D

var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# Globalから設定を取得
	var settings = Global.config_data.get("settings", {}).get("boss", {})
	var tex_key = settings.get("texture", "")
	if Global.textures.has(tex_key):
		sprite.texture = Global.textures[tex_key]
	
	# 初期位置
	var pos = settings.get("initial_position", [576, 150])
	position = Vector2(pos[0], pos[1])
