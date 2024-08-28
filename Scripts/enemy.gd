extends SpotLight3D

@onready var ray = $RayCast3D2
@onready var ray2 = $RayCast3D3
@onready var ray3 = $RayCast3D4
@onready var gamemanager = %Gamemanager
@export var anim :AnimationPlayer

func _ready():
	anim.play("Loop")

func _process(delta):
	if ray.is_colliding() or ray2.is_colliding() or ray3.is_colliding():
		gamemanager._retry()
	
