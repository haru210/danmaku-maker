# GimmickManager.gd
extends Node2D

# ギミックとして表示されているノードの辞書 (name: Node)
var active_gimmicks: Dictionary = {}

func handle_event(event: Dictionary) -> void:
	if event.get("type") != "gimmick":
		return
	
	var action = event.get("action", "display")
	match action:
		"display":
			_display_gimmick(event)

func _display_gimmick(data: Dictionary) -> void:
	var tex_key = data.get("texture", "")
	if not Global.textures.has(tex_key):
		printerr("Gimmick Error: Texture not found: ", tex_key)
		return
	
	var sprite = Sprite2D.new()
	sprite.texture = Global.textures[tex_key]
	
	# 位置設定
	var pos = data.get("position", [0, 0])
	sprite.position = Vector2(pos[0], pos[1])
	
	# スケール設定
	var sc = data.get("scale", [1, 1])
	sprite.scale = Vector2(sc[0], sc[1])
	
	# フェードイン演出
	var fade_time = data.get("fade_in", 0.0)
	if fade_time > 0:
		sprite.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 1.0, fade_time)
	
	add_child(sprite)
	
	# 名前があれば管理対象にする
	var g_name = data.get("name", "")
	if not g_name.is_empty():
		active_gimmicks[g_name] = sprite
