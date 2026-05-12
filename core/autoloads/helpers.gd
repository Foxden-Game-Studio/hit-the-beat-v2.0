extends Node

func load_audio_file(path: String) -> AudioStreamMP3:
    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        var sound_data = file.get_buffer(file.get_length())

        var new_stream = AudioStreamMP3.new()
        new_stream.data = sound_data

        return new_stream
    else:
        printerr("Error: File not found at ", path)
        return null