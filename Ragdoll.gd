extends Skeleton3D


var gameData = preload("res://Resources/GameData.tres")

@export var hitBone: PhysicalBone3D

var simulationTime = 4.0
var simulationTimer = 0.0
var isActive = false

func _ready():
	DeactivateBones()

func DeactivateBones():
	physical_bones_stop_simulation()

	for child in get_children():
		if child is PhysicalBone3D:
			child.axis_lock_linear_x = true
			child.axis_lock_linear_y = true
			child.axis_lock_linear_z = true
			child.axis_lock_angular_x = true
			child.axis_lock_angular_y = true
			child.axis_lock_angular_z = true
			child.get_child(0).disabled = true

func ActivateBones():
	physical_bones_start_simulation()

	for child in get_children():
		if child is PhysicalBone3D:
			child.axis_lock_linear_x = false
			child.axis_lock_linear_y = false
			child.axis_lock_linear_z = false
			child.axis_lock_angular_x = false
			child.axis_lock_angular_y = false
			child.axis_lock_angular_z = false
			child.get_child(0).disabled = false

func _physics_process(delta):
	if isActive:
		simulationTimer += delta

		if simulationTimer > simulationTime:
			DeactivateBones()
			owner.Pause()
			print("AI: Process ended")
			isActive = false

func Activate():
	isActive = true
	var forceDirection: Vector3
	forceDirection = - gameData.playerVector
	hitBone.linear_velocity = forceDirection * 20.0
	ActivateBones()
