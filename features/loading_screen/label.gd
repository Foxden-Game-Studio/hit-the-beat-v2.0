extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Fetch the plain translated word
	var translated_text = tr("loading")
	
	# 2. Inject it into the BBCode string using format string syntax (%s)
	self.text = "[wave amp=20.0 freq=5.0 connected=1]%s...[/wave]" % translated_text
