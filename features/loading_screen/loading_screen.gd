extends Control

signal scene_loading_finished(scene: PackedScene)

var scene_path: String
var loading = false

func start_loading() -> void:
	if !ResourceLoader.exists(scene_path):
		printerr("Error: Scene not found")
		return
	
	var error = ResourceLoader.load_threaded_request(scene_path)
	if error == OK:
		loading = true

func _process(_delta: float) -> void:
	if not loading:
		return
		
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			scene_loading_finished.emit(ResourceLoader.load_threaded_get(scene_path))
			loading = false
			queue_free()
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Something went wrong with loading!")
			loading = false

func set_to_load_scene(scene_path: String) -> void:
	self.scene_path = scene_path
