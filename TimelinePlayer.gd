# TimelinePlayer.gd
extends Node

var current_time: float = 0.0
var events: Array = []
var event_index: int = 0
var is_playing: bool = false

signal event_triggered(event_data: Dictionary)

func _process(delta: float) -> void:
	if not is_playing:
		return
	
	current_time += delta
	
	# 時間に達したイベントを順次発火
	while event_index < events.size() and events[event_index].get("time", 0.0) <= current_time:
		event_triggered.emit(events[event_index])
		event_index += 1
	
	# すべてのイベントが終了した場合
	if event_index >= events.size():
		print("Timeline finished.")
		is_playing = false

func start(timeline_data: Array) -> void:
	events = timeline_data
	# 時間順にソート（念のため）
	events.sort_custom(func(a, b): return a.get("time", 0.0) < b.get("time", 0.0))
	
	current_time = 0.0
	event_index = 0
	is_playing = true
	print("Timeline started.")
