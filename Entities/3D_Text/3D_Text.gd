class_name Text_3D extends Sprite3D

@export var label_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$SubViewport/Label.text = label_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func Set_3D_Text(text):
	$SubViewport/Label.text = text
