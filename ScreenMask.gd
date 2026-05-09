extends Node2D

func _ready() -> void:
	# 描画更新のために
	get_viewport().size_changed.connect(queue_redraw)

func _draw() -> void:
	var view_size = get_viewport().get_visible_rect().size
	var game_size = Global.get_game_size()
	
	if game_size == view_size:
		return
		
	var offset = (view_size - game_size) / 2.0
	
	# 上
	draw_rect(Rect2(0, 0, view_size.x, offset.y), Color.BLACK)
	# 下
	draw_rect(Rect2(0, view_size.y - offset.y, view_size.x, offset.y), Color.BLACK)
	# 左
	draw_rect(Rect2(0, offset.y, offset.x, game_size.y), Color.BLACK)
	# 右
	draw_rect(Rect2(view_size.x - offset.x, offset.y, offset.x, game_size.y), Color.BLACK)
