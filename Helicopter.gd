extends Node3D

@export var parts: Node3D
@export var mainRotor: Node3D
@export var tailRotor: Node3D

var moveSpeed = 0.0
var rotationSpeed = 0.4

var distanceToWaypoint = 0.0
var waypoint: Vector3
var isRotating = false

var rotationTime = 10.0
var rotationTimer = 0.0

func _ready():
    global_position = Vector3(randf_range(-500, 500), 100, randf_range(-500, 500))
    waypoint = Vector3(randf_range(-500, 500), 100, randf_range(-500, 500))
    look_at(waypoint, Vector3.UP)

func _physics_process(delta):
    RotorBlades(delta)

    if !isRotating:
        global_position = position.move_toward(waypoint, delta * moveSpeed)
        parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 10.0, delta)

    distanceToWaypoint = position.distance_to(waypoint)


    if !isRotating:
        if distanceToWaypoint < 50.0:
            moveSpeed = lerp(moveSpeed, 5.0, delta)
        else:
            moveSpeed = lerp(moveSpeed, 20.0, delta)


    if !isRotating && distanceToWaypoint == 0:
        isRotating = true
        SetWaypoint()


    if isRotating:
        moveSpeed = lerp(moveSpeed, 0.0, delta)

        var waypointDirection = global_position - Vector3(waypoint.x, 0.0, waypoint.z)
        rotation.y = lerp_angle(rotation.y, atan2(waypointDirection.x, waypointDirection.z), delta * rotationSpeed)
        rotationTimer += delta

        parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)


        if rotationTimer >= rotationTime:
            rotationTimer = 0.0
            isRotating = false

func RotorBlades(delta):
    mainRotor.rotation.y += delta * 15.0
    tailRotor.rotation.x += delta * 20.0

func SetWaypoint():
    waypoint = Vector3(randf_range(-500, 500), 100, randf_range(-500, 500))
