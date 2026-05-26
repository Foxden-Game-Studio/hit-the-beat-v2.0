extends TextureRect

@export var frame_width: int   # Width of one frame in pixels
@export var frame_height: int  # Height of one frame in pixels
@export var total_frames: int  # Total number of frames in the animation
@export var fps: float         # Frames per second

var current_frame: int = 0
var time_passed: float = 0.0
var atlas_tex: AtlasTexture
var frames_per_row: int = 0

func _ready():
	# 1. Get the AtlasTexture we set up in the editor
	if texture is AtlasTexture:
		atlas_tex = texture
		
		# Calculate how many frames fit horizontally across the sheet
		var sheet_width = atlas_tex.atlas.get_width()
		frames_per_row = int(sheet_width / frame_width)
		
		# Set the initial frame size
		atlas_tex.region = Rect2(0, 0, frame_width, frame_height)
	else:
		push_error("Texture must be an AtlasTexture!")

func _process(delta: float):
	if not atlas_tex:
		return
		
	# 2. Track time to handle the playback speed
	time_passed += delta
	var time_per_frame = 1.0 / fps
	
	if time_passed >= time_per_frame:
		time_passed -= time_per_frame
		
		# Advance to next frame (and loop back to 0 at the end)
		current_frame = (current_frame + 1) % total_frames
		
		# 3. Update the visible frame region
		update_frame_region()

func update_frame_region():
	# Calculate grid coordinates (column and row)
	var column = current_frame % frames_per_row
	var row = current_frame / frames_per_row
	
	# Position the "window" over the current frame
	atlas_tex.region.position.x = column * frame_width
	atlas_tex.region.position.y = row * frame_height
