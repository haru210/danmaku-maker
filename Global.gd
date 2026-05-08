# Global.gd
extends Node

# --- パス関連 ---
var project_root_path: String = ""   # 選択されたフォルダの絶対パス
var current_json_path: String = ""    # 現在実行中のJSONファイルの絶対パス

# --- データ関連 ---
var config_data: Dictionary = {}      # 現在のJSONから読み込んだデータ
var textures: Dictionary = {}        # 読み込んだ ImageTexture (名前: Texture2D)

# --- ヘルパー ---
func get_external_path(relative_path: String) -> String:
	if project_root_path.is_empty():
		return relative_path
	return project_root_path.path_join(relative_path)

func clear_data() -> void:
	config_data.clear()
	textures.clear()
	current_json_path = ""
