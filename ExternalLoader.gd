# ExternalLoader.gd
extends Node

# すべてのリソースをロードするメイン関数
func load_all() -> bool:
	if Global.current_json_path.is_empty():
		printerr("JSONパスが指定されていません。")
		return false
	
	# データをクリア
	Global.textures.clear()
	Global.config_data.clear()
	
	# 1. JSONの読み込み
	var json_data = load_json(Global.current_json_path)
	if json_data.is_empty():
		return false
	Global.config_data = json_data
	
	# 2. 画像リソースの抽出とロード
	load_textures_from_config(Global.config_data)
	
	print("ロード完了: ", Global.textures.keys())
	return true

# JSONファイルを読み込んで辞書に変換
func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("JSONファイルを開けませんでした: ", path)
		return {}
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON解析エラー: ", json.get_error_message(), " at line ", json.get_error_line())
		return {}
	
	return json.data

# JSONデータ内からテクスチャ指定を自動で見つけてロード
func load_textures_from_config(data: Variant) -> void:
	if data is Dictionary:
		for key in data:
			if key == "texture" and data[key] is String:
				_load_texture(data[key])
			else:
				load_textures_from_config(data[key])
	elif data is Array:
		for item in data:
			load_textures_from_config(item)

# 個別の画像を ImageTexture として読み込みキャッシュする
func _load_texture(relative_path: String) -> void:
	if Global.textures.has(relative_path):
		return # すでにロード済み
	
	var full_path = Global.get_external_path(relative_path)
	print("Loading image from: ", full_path)
	
	if not FileAccess.file_exists(full_path):
		printerr("画像ファイルが物理的に存在しません: ", full_path)
		return
	
	var image = Image.load_from_file(full_path)
	if image and not image.is_empty():
		var tex = ImageTexture.create_from_image(image)
		Global.textures[relative_path] = tex
		print("テクスチャをロードしました: ", relative_path, " (Size: ", image.get_size(), ")")
	else:
		printerr("Image.load_from_file が失敗しました。形式が未対応か壊れている可能性があります: ", full_path)
