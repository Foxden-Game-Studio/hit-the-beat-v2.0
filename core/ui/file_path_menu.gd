extends HBoxContainer

@onready var line_edit: LineEdit = $LineEdit
@onready var menu_button: MenuButton = $MenuButton

func _ready() -> void:
	var popup = menu_button.get_popup()

	var songs_files = DirAccess.get_files_at(GlobalDefinitions.USER_SONGS_DIR)

	for i in range(songs_files.size()):
		if not songs_files[i].ends_with(".mp3"):
			continue

		var full_path = GlobalDefinitions.USER_SONGS_DIR + songs_files[i]
		var file_name = songs_files[i]

		popup.add_item(file_name)
		popup.set_item_metadata(i-1, full_path)
	
	popup.id_pressed.connect(_on_path_selected)

func _on_path_selected(id: int):
	var selected_path: String = menu_button.get_popup().get_item_metadata(id)

	line_edit.text = selected_path
	line_edit.grab_focus()	
