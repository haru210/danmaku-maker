# Main.gd
extends Node

func _ready() -> void:
	# 起動直後にフォルダ選択ダイアログを表示
	open_directory_dialog()

func open_directory_dialog() -> void:
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.title = "弾幕コンセプトフォルダを選択してください"
	
	dialog.dir_selected.connect(_on_dir_selected)
	dialog.canceled.connect(func(): get_tree().quit())
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.5)

func _on_dir_selected(path: String) -> void:
	print("Selected path: ", path)
	Global.project_root_path = path
	scan_for_json_files(path)

func scan_for_json_files(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		printerr("フォルダを開けませんでした: ", path)
		return
	
	var json_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			json_files.append(file_name)
		file_name = dir.get_next()
	
	if json_files.size() == 0:
		print("JSONファイルが見つかりません。")
		# 本来はここでユーザーに通知する
		return
	
	print("見つかったJSON: ", json_files)
	# 将来的にはここでJSONを選択するUIを表示する
	# 現時点では便宜上、最初のJSON（あるいは config.json）を自動選択する
	var target_json = "config.json" if "config.json" in json_files else json_files[0]
	start_project(target_json)

func start_project(json_filename: String) -> void:
	Global.current_json_path = Global.get_external_path(json_filename)
	print("Starting project with: ", Global.current_json_path)
	
	# Loaderを動的に生成して実行
	var loader = load("res://ExternalLoader.gd").new()
	add_child(loader)
	if loader.load_all():
		print("Project loaded successfully!")
		setup_game_engine()
	
	loader.queue_free()

func setup_game_engine() -> void:
	# 1. ギミックマネージャーの作成
	var gimmick_manager = load("res://GimmickManager.gd").new()
	gimmick_manager.name = "GimmickManager"
	add_child(gimmick_manager)
	
	# 2. ボスの作成
	var boss = load("res://Boss.gd").new()
	boss.name = "Boss"
	add_child(boss)
	
	# 3. 自機の作成
	var player = load("res://Player.gd").new()
	player.name = "Player"
	add_child(player)
	
	# 4. タイムラインプレイヤーの作成
	var timeline_player = load("res://TimelinePlayer.gd").new()
	timeline_player.name = "TimelinePlayer"
	add_child(timeline_player)
	
	# タイムラインのイベントをギミックマネージャーに接続
	timeline_player.event_triggered.connect(gimmick_manager.handle_event)
	
	# タイムライン開始
	if Global.config_data.has("timeline"):
		timeline_player.start(Global.config_data["timeline"])
