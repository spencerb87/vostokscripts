extends RayCast3D

var pickup

func _physics_process(_delta):
    if is_colliding():
        pickup.Stick(get_collider())
