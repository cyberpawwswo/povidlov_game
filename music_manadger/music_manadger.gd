extends Node


var current_playlist_path: String
var last_current_playlist_path: String

var play_list: Array[AudioStream]

var current_song: AudioStream
var next_song: AudioStream

@onready var player_cur: AudioStreamPlayer = $CurrentMusic
@onready var player_next: AudioStreamPlayer = $NextMusic

func _process(delta: float) -> void:
	if last_current_playlist_path != current_playlist_path and not current_playlist_path.is_empty():
		play_list = get_audio_streams_from_folder(current_playlist_path)
		last_current_playlist_path = current_playlist_path

	if not play_list.is_empty():
		if not current_song:
			current_song = play_list[0]
			next_song = get_next_music()
			player_cur.stream = current_song
			player_cur.play()

func set_playlist(playlist_path):
	current_playlist_path = playlist_path
	play_list = get_audio_streams_from_folder(current_playlist_path)
	last_current_playlist_path = current_playlist_path




func get_next_music() -> AudioStream:
	if current_song:
		var idx = play_list.find(current_song)
		
		if idx == play_list.size() - 1:
			return play_list[0]
		else:
			return play_list[idx + 1]
	return null

func get_audio_streams_from_folder(folder_path: String) -> Array[AudioStream]:
	var audio_streams: Array[AudioStream] = []
	
	# Убедимся, что путь заканчивается на /
	if not folder_path.ends_with("/"):
		folder_path += "/"
	
	# Получаем список файлов и папок
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Не удалось открыть папку: " + folder_path)
		return audio_streams
	
	dir.list_dir_begin() # TODO в Godot 4.2+ list_dir_begin() устарел, но всё ещё работает
	
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			# Рекурсивно обрабатываем подпапки (исключая . и ..)
			if file_name != "." and file_name != "..":
				var subfolder_path = folder_path + file_name + "/"
				audio_streams.append_array(get_audio_streams_from_folder(subfolder_path))
		else:
			# Проверяем, является ли файл аудио-ресурсом
			var full_path = folder_path + file_name
			var resource = load(full_path)
			
			if resource is AudioStream:
				audio_streams.append(resource)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print(audio_streams)
	return audio_streams

func set_volume(idx: int, volum: float):
	AudioServer.set_bus_volume_db(idx, volum)


func disable_audio():
	AudioServer.set_bus_volume_db(0, -100)

func enable_audio():
	AudioServer.set_bus_volume_db(0, 0)

func _on_current_music_finished() -> void:
	current_song = next_song
	player_next.stream = current_song
	next_song = get_next_music()
	player_next.play()
	print(current_song, next_song)


func _on_next_music_finished() -> void:
	current_song = next_song
	player_cur.stream = current_song
	next_song = get_next_music()
	player_cur.play()
	print('1')
