# Global.gd
extends Node

# --- パス関連 ---
var project_root_path: String = ""   # 選択されたフォルダの絶対パス
var current_json_path: String = ""    # 現在実行中のJSONファイルの絶対パス

# --- データ関連 ---
var config_data: Dictionary = {}      # 現在のJSONから読み込んだデータ
var textures: Dictionary = {}        # 読み込んだ ImageTexture (名前: Texture2D)
var game_size: Vector2 = Vector2.ZERO # ゲームの論理解像度

# --- ヘルパー ---
func get_game_size() -> Vector2:
	if game_size == Vector2.ZERO:
		return get_viewport().get_visible_rect().size
	return game_size

func get_game_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, get_game_size())
func get_external_path(relative_path: String) -> String:
	if project_root_path.is_empty():
		return relative_path
	return project_root_path.path_join(relative_path)

func clear_data() -> void:
	config_data.clear()
	textures.clear()
	current_json_path = ""
