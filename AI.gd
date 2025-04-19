extends CharacterBody3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


var smoke = preload("res://Resources/Smoke.tscn")
var flashLarge = preload("res://Resources/Flash_Large.tscn")
var hit = preload("res://Resources/Hit.tscn")

@export_group("References")
@export var spineData: SpineData
@export var weapons: Node3D
@export var backpacks: Node3D
@export var secondaries: Node3D
@export var headlamps: Node3D
@export var skeleton: Skeleton3D
@export var mesh: MeshInstance3D
@export var chest: PhysicalBone3D
@export var animator: AnimationTree
@export var collision: CollisionShape3D
@export var container: Node3D
@export var light: OmniLight3D
@export var clothing: Array[Material]

@export_group("Equipment")
@export var allowClothing = false
@export var allowBackpacks = false
@export var allowHeadlamps = false
@export var allowSecondaries = false

@onready var agent: NavigationAgent3D = $Agent
@onready var sensor = $Sensor
@onready var LOS = $Sensor / LOS
@onready var fire = $Sensor / Fire
@onready var below = $Raycasts / Below
@onready var forward = $Raycasts / Forward
@onready var evader = $Evader
@onready var gizmo = $Gizmo
@onready var notifier = $Notifier
@onready var eyes = $AI / Armature / Skeleton3D / Eyes


enum State{Idle, Group, Wander, Guard, Patrol, Hide, Ambush, Evade, Cover, Defend, Shift, Combat, Hunt, Attack, Vantage}
var currentState = State.Idle

var pause: bool
var AISpawner
var health = 100


var speed = 0.0
var turnSpeed = 0.0
var movementSpeed = 0.0
var movementRotation = 0.0
var movementVelocity = 0.0
var lerpToPoint = false


var waypoints: Node3D
var patrols: Node3D
var covers: Node3D
var hides: Node3D
var groups: Node3D
var currentArea: int
var currentPoint: Node3D
var previousPoint: Node3D


var weapon: Node3D
var backpack: Node3D
var secondary: Node3D
var weaponData: WeaponData
var muzzle: Node3D
var headlamp: Node3D
var lamp: Light3D
var flare: Node3D
var lampActive = false
var lampAvailable = false


var LKL: Vector3
var LKLSpeed = 2.0
var lastKnownLocation: Vector3
var playerVisible = false
var playerPosition: Vector3
var playerDistance3D = 0.0
var playerDistance2D = 0.0
var fireVector = 0.0
var lookVector = 0.0
var headBone = 14


var sensorDelay = 10.0
var sensorActive = false
var sensorTimer = 0.0
var sensorCycle = 0.1


var navigationMap
var map


var fireTime = 1.0
var fireAccuracy = 1.0
var selectorTime = 1.0
var selectorRoll = 0
var fullAuto = false


var guardTimer: float
var guardCycle: float


var ambushTimer: float
var ambushCycle: float


var defendTimer: float
var defendCycle: float


var combatTimer: float
var combatCycle: float


var shiftTimer: float
var shiftCycle: float


var huntTimer: float
var huntCycle: float


var attackTimer: float
var attackCycle: float


var dead = false
var deathTime = 300.0
var deathTimer = 0.0


var headlampTimer: float
var headlampCycle: float


var interactionTarget
var interactionTime = 0.2
var interactionTimer = 0.0


var muzzleFlash = false
var flashTimer = 0.0


var fireDetected = false
var fireDetectionTimer = 0.0
var fireDetectionTime = 5.0
var extraVisibility = 0.0


var spineWeight = 0.0
var spineX = 0.0
var spineY = 0.0
var spineZ = 0.0
var aimSpeed = 1.0
var spineTarget: Vector3


var impact = false
var impulseTime = 0.1
var impulseTimer = 0.0
var recoveryTime = 1.0
var recoveryTimer = 0.0
var impulseTarget: Vector3


var strafeDirection: float
var targetStrafe: float
var north = false
var south = false

var north1 = false
var north2 = false
var south1 = false
var south2 = false


@onready var poles = $Poles
@onready var N1 = $Poles / AI_Pole_N1
@onready var N2 = $Poles / AI_Pole_N2
@onready var S1 = $Poles / AI_Pole_S1
@onready var S2 = $Poles / AI_Pole_S2

var poleTimer: float
var poleCycle = 0.1


var AIOnScreen = false
var IKActive = false



func _ready():
	call_deferred("Initialize")

func Initialize():

	await get_tree().physics_frame


	map = get_tree().current_scene.get_node("/root/Map")
	navigationMap = get_world_3d().get_navigation_map()
	AISpawner = get_tree().current_scene.get_node("/root/Map/AI")


	DeactivateEquipment()
	DeactivateContainer()


	SelectWeapon()

	if allowBackpacks:
		SelectBackpack()
	if allowSecondaries:
		SelectSecondary()
	if allowClothing:
		SelectClothing()
	if allowHeadlamps:
		SelectHeadlamp()


	if AISpawner.showGizmos:
		ShowGizmos()
	else:
		HideGizmos()


	if !AISpawner.noAnimationDelay:
		await get_tree().create_timer(randi_range(0, 2)).timeout;


	if !AISpawner.noSensorDelay:
		await get_tree().create_timer(sensorDelay).timeout;

	sensorActive = true



func _physics_process(delta):
	if pause:
		return

	if lampAvailable:
		Headlamp(delta)

	if dead:
		DeathTimer(delta)
		return

	if sensorActive && !gameData.isDead && !gameData.isFlying:
		Parameters(delta)
		Sensor(delta)
		FireDetection(delta)
		Evader()

	Interactor(delta)
	States(delta)
	Movement(delta)
	Rotation(delta)
	Poles(delta)
	Spine(delta)
	Aim(delta)
	MuzzleFlash(delta)
	Optimizer(delta)



func ActivateWanderer():
	Activate()
	ChangeState("Wander")

func ActivateHider():
	Activate()
	ChangeState("Ambush")

func ActivateGuard():
	Activate()
	ChangeState("Guard")

func ActivateGroup():
	Activate()
	ChangeState("Group")

func Pause():

	if !dead:
		hide()


	pause = true


	sensor.monitoring = false
	evader.monitoring = false
	below.enabled = false
	forward.enabled = false
	LOS.enabled = false
	fire.enabled = false

	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	skeleton.process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED

func Activate():

	show()


	pause = false


	animator.active = true
	skeleton.show_rest_only = false


	sensor.monitoring = true
	evader.monitoring = true
	below.enabled = true
	forward.enabled = true
	LOS.enabled = true
	fire.enabled = true

	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	skeleton.process_mode = ProcessMode.PROCESS_MODE_INHERIT

func Death():
	dead = true


	light.hide()


	sensor.monitoring = false
	evader.monitoring = false
	below.enabled = false
	forward.enabled = false
	LOS.enabled = false
	fire.enabled = false


	animator.active = false


	collision.disabled = true


	agent.velocity = Vector3.ZERO


	ActivateContainer()


	weapon.collision.disabled = false


	if backpack:
		backpack.collision.disabled = false


	if secondary:
		secondary.collision.disabled = false


	if headlamp:
		headlamp.collision.disabled = false


	skeleton.Activate()


	skeleton.set_bone_global_pose_override(spineData.bone, skeleton.get_bone_pose(spineData.bone), 0.0, true)


	AISpawner.activeAgents -= 1


	HideGizmos()
	agent.debug_enabled = false


func DeathTimer(delta):
	deathTimer += delta

	if deathTimer > deathTime:
		queue_free()



func SelectWeapon():
	var randomIndex


	if AISpawner.forcePistol:
		randomIndex = 0

	elif AISpawner.forceRifle:
		randomIndex = weapons.get_child_count() - 1

	else:
		randomIndex = randi_range(0, weapons.get_child_count() - 1)


	weapon = weapons.get_child(randomIndex)
	weaponData = weapon.slotData.itemData
	weapon.show()


	for child in weapon.get_children():
		if child.name == "Muzzle":
			muzzle = child


	var newSlotData = SlotData.new()
	newSlotData.itemData = weapon.slotData.itemData
	newSlotData.ammo = randi_range(1, newSlotData.itemData.magazineSize)
	newSlotData.condition = randi_range(5, 50)
	weapon.slotData = newSlotData


	if newSlotData.itemData.action == 2 || newSlotData.itemData.action == 3:
		newSlotData.chamber = 1


	if newSlotData.itemData.action == 1:
		animator["parameters/conditions/Pistol"] = true
		animator["parameters/conditions/Rifle"] = false
	else:
		animator["parameters/conditions/Pistol"] = false
		animator["parameters/conditions/Rifle"] = true

func SelectBackpack():

	var backpackRoll = randi_range(0, 100)


	if backpackRoll < 10:

		var randomIndex = randi_range(0, backpacks.get_child_count() - 1)


		backpack = backpacks.get_child(randomIndex)
		backpack.show()


		var chestCollider: CollisionShape3D = chest.get_child(0)
		chestCollider.shape.size.z = 0.4
		chestCollider.position.z -= 0.05

func SelectSecondary():

	var secondaryRoll = randi_range(0, 100)


	if secondaryRoll < 10:

		var randomIndex = randi_range(0, secondaries.get_child_count() - 1)


		secondary = secondaries.get_child(randomIndex)
		secondary.show()


		var newSlotData = SlotData.new()
		newSlotData.itemData = secondary.slotData.itemData
		newSlotData.ammo = randi_range(1, newSlotData.itemData.magazineSize)
		newSlotData.condition = randi_range(5, 50)
		secondary.slotData = newSlotData


		if newSlotData.itemData.action == 2 || newSlotData.itemData.action == 3:
			newSlotData.chamber = 1

func SelectClothing():

	var availableClothing = clothing.size()

	if availableClothing != 0:

		var randomIndex = randi_range(0, availableClothing - 1)

		var clothingMaterial = clothing[randomIndex]

		mesh.set_surface_override_material(0, clothingMaterial)

func SelectHeadlamp():

	var lampRoll = randi_range(0, 100)


	if lampRoll < 10 || AISpawner.forceHeadlamps:

		var randomIndex = randi_range(0, headlamps.get_child_count() - 1)


		headlamp = headlamps.get_child(randomIndex)


		for child in headlamp.get_children():
			if child.name == "Lamp":
				lamp = child
			if child.name == "Flare":
				flare = child


		lampAvailable = true
		lampActive = false
		headlamp.show()
		lamp.hide()
		flare.hide()


		lamp.spot_range = 0.0

func Headlamp(delta):
	headlampTimer += delta


	if headlampTimer > headlampCycle:


		if gameData.TOD != 4:


			if lampActive:
				PlayHeadlampAudio()

			lamp.spot_range = 0.0
			lampActive = false
			lamp.hide()
			flare.hide()


		else:

			var activationRoll = randi_range(0, 100)


			if activationRoll < 50 && currentState != State.Ambush || AISpawner.forceHeadlamps:


				if !lampActive:
					PlayHeadlampAudio()

				lamp.spot_range = 20.0
				lampActive = true
				lamp.show()
				flare.show()


			else:


				if lampActive:
					PlayHeadlampAudio()

				lamp.spot_range = 0.0
				lampActive = false
				lamp.hide()
				flare.hide()


		headlampTimer = 0.0
		headlampCycle = randf_range(10, 20)


	if dead:

		lamp.light_energy = lerp(lamp.light_energy, 0.0, delta)
		flare.scale = lerp(flare.scale, Vector3.ZERO, delta)


		if lamp.light_energy < 0.1:
			lamp.hide()
			flare.hide()
			lamp.spot_range = 0.0
			lampActive = false
			lampAvailable = false
			print("Lamp deactivated")


	elif lampActive:

		var flareScale = lookVector
		flare.scale = Vector3(flareScale, flareScale, flareScale)

func DeactivateEquipment():

	for child in weapons.get_children():
		child.collision.disabled = true
		child.hide()


	for child in backpacks.get_children():
		child.collision.disabled = true
		child.hide()


	for child in secondaries.get_children():
		child.collision.disabled = true
		child.hide()


	for child in headlamps.get_children():
		child.collision.disabled = true
		child.hide()

func ActivateContainer():
	container.get_child(0).get_child(0).disabled = false

func DeactivateContainer():
	container.get_child(0).get_child(0).disabled = true



func Parameters(delta):
	LKL = lerp(LKL, lastKnownLocation, delta * LKLSpeed)
	playerPosition = gameData.playerPosition
	playerDistance3D = global_transform.origin.distance_to(playerPosition)
	playerDistance2D = Vector2(global_position.x, global_position.z).distance_to(Vector2(playerPosition.x, playerPosition.z))
	var dir = (playerPosition - global_position).normalized()
	lookVector = dir.dot(headlamps.global_basis.z)
	fireVector = dir.dot(gameData.playerVector)


	if currentState == State.Group:
		sensorCycle = 2.0
		LKLSpeed = 2.0
	else:

		if playerDistance3D < 10 && playerVisible:
			sensorCycle = 0.02
			LKLSpeed = 4.0

		elif playerDistance3D > 10 && playerDistance3D < 50:
			sensorCycle = 0.1
			LKLSpeed = 2.0

		elif playerDistance3D > 50:
			sensorCycle = 0.5
			LKLSpeed = 1.0

func Sensor(delta):
	if AISpawner.sensorBlocked:
		return

	sensorTimer += delta

	if sensorTimer > sensorCycle:
		var overlaps = sensor.get_overlapping_areas()


		sensor.position.y = eyes.position.y
		sensor.rotation.y = eyes.rotation.y
		sensor.rotation.x = eyes.rotation.x


		if !playerVisible:
			Hearing()


		if overlaps.size() == 0:
			playerVisible = false
			UpdateGizmos()
			return


		if overlaps.size() > 0:
			for overlap in overlaps:


				if overlap.name == "Detection":
					LineOfSight(overlap.global_transform.origin)


		sensorTimer = 0.0

func Hearing():
	if (playerDistance3D < 20 && gameData.isRunning) || (playerDistance3D < 5 && gameData.isWalking):

		if currentState != State.Ambush:
			lastKnownLocation = playerPosition

		if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
			Decision()

		elif currentState == State.Group:
			AISpawner.AlertGroup()

func LineOfSight(target: Vector3):

	if gameData.TOD == 4 && !gameData.flashlight && !lampActive:
		LOS.target_position = Vector3(0, 0, 25 + extraVisibility)

	elif gameData.TOD == 4 && !gameData.flashlight && lampActive:
		LOS.target_position = Vector3(0, 0, 50 + extraVisibility)

	else:
		LOS.target_position = Vector3(0, 0, 100)


	LOS.look_at(target, Vector3.UP, true)
	LOS.force_raycast_update()


	if LOS.is_colliding() && LOS.get_collider().name == "Controller":

		lastKnownLocation = playerPosition

		playerVisible = true
		UpdateGizmos()


		if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
			Decision()

		elif currentState == State.Group:
			AISpawner.AlertGroup()

		elif currentState == State.Ambush:
			ChangeState("Combat")
	else:
		playerVisible = false
		UpdateGizmos()

func FireDetection(delta):

	if gameData.isFiring && !playerVisible:

		if fireVector > 0.95:

			lastKnownLocation = playerPosition

			if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
				Decision()

			elif currentState == State.Group:
				AISpawner.AlertGroup()

			elif currentState == State.Ambush:
				ChangeState("Combat")


			fireDetected = true
			extraVisibility = 50.0


		elif playerDistance3D < 50:

			if currentState != State.Ambush:
				lastKnownLocation = playerPosition

			if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
				Decision()

			elif currentState == State.Group:
				AISpawner.AlertGroup()


			fireDetected = true
			extraVisibility = 50.0


	if fireDetected:
		fireDetectionTimer += delta


		if fireDetectionTimer > fireDetectionTime:
			extraVisibility = 0.0
			fireDetectionTimer = 0.0
			fireDetected = false

func Evader():
	evader.look_at(playerPosition, Vector3.UP)

func Optimizer(_delta):
	if notifier.is_on_screen() && !AIOnScreen:
		animator.active = true
		AIOnScreen = true
	elif !notifier.is_on_screen() && AIOnScreen:
		animator.active = false
		AIOnScreen = false



func Interactor(delta):
	forward.global_rotation.y = atan2(velocity.x, velocity.z)
	interactionTimer += delta

	if interactionTimer > interactionTime:
		if forward.is_colliding():
			interactionTarget = forward.get_collider()

			if interactionTarget.is_in_group("Interactable"):
				if interactionTarget.owner is Door && !interactionTarget.owner.isOpen:
					interactionTarget.owner.Interact()
					interactionTarget.owner.isOccupied = true

		interactionTimer = 0.0



func Movement(delta):
	movementSpeed = move_toward(movementSpeed, speed, delta * 5.0)
	movementRotation = move_toward(movementRotation, turnSpeed, delta * 5.0)
	animator["parameters/Rifle/Movement/blend_position"] = movementSpeed
	animator["parameters/Pistol/Movement/blend_position"] = movementSpeed

	if currentState == State.Group || currentState == State.Guard || currentState == State.Ambush || currentState == State.Defend:
		velocity = lerp(velocity, Vector3.ZERO, delta * 2.0)
	else:
		var moveTarget: Vector3 = agent.get_next_path_position()
		var moveDirection: Vector3 = (moveTarget - global_position).normalized()
		velocity = lerp(velocity, moveDirection * movementSpeed, delta * movementVelocity)

		if !AISpawner.noVelocity:
			move_and_slide()

func Rotation(delta):

	if currentState == State.Wander || currentState == State.Patrol || currentState == State.Cover || currentState == State.Vantage || currentState == State.Hide || currentState == State.Evade || currentState == State.Attack:
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * movementRotation)


	elif currentState == State.Guard || currentState == State.Ambush:
		rotation.y = lerp_angle(rotation.y, currentPoint.rotation.y, delta * movementRotation)
		animator["parameters/Rifle/Hunt/blend_position"] = Vector2.ZERO
		animator["parameters/Pistol/Hunt/blend_position"] = Vector2.ZERO


	elif currentState == State.Defend:
		var playerDirection = global_position - Vector3(LKL.x, 0.0, LKL.z)
		rotation.y = lerp_angle(rotation.y, atan2( - playerDirection.x, - playerDirection.z), delta * movementRotation)

		var turnDirection = angle_difference(rotation.y, atan2( - playerDirection.x, - playerDirection.z))
		animator["parameters/Rifle/Defend/blend_position"] = - turnDirection * 10.0
		animator["parameters/Pistol/Defend/blend_position"] = - turnDirection * 10.0


	elif currentState == State.Combat || currentState == State.Hunt:
		poleTimer += delta


		if poleTimer > poleCycle:
			var nearestPole = GetNearestPole()

			if nearestPole == N1:
				north = true
				north1 = true
			elif nearestPole == N2:
				north = true
				north2 = true
			elif nearestPole == S1:
				south = true
				south1 = true
			elif nearestPole == S2:
				south = true
				south2 = true

			poleTimer = 0.0


		var N1Dir = global_position - Vector3(N1.global_position.x, 0.0, N1.global_position.z)
		var N2Dir = global_position - Vector3(N2.global_position.x, 0.0, N2.global_position.z)
		var S1Dir = global_position - Vector3(S1.global_position.x, 0.0, S1.global_position.z)
		var S2Dir = global_position - Vector3(S1.global_position.x, 0.0, S2.global_position.z)


		if north1:
			rotation.y = lerp_angle(rotation.y, atan2( - N1Dir.x, - N1Dir.z), delta * 2)
			targetStrafe = 1.0
		elif north2:
			rotation.y = lerp_angle(rotation.y, atan2( - N2Dir.x, - N2Dir.z), delta * 2)
			targetStrafe = 1.0
		elif south1:
			rotation.y = lerp_angle(rotation.y, atan2( - S1Dir.x, - S1Dir.z), delta * 2)
			targetStrafe = -1.0
		elif south2:
			rotation.y = lerp_angle(rotation.y, atan2( - S2Dir.x, - S2Dir.z), delta * 2)
			targetStrafe = -1.0

		strafeDirection = move_toward(strafeDirection, targetStrafe, delta * 2)
		animator["parameters/Rifle/Combat/blend_position"] = strafeDirection
		animator["parameters/Rifle/Hunt/blend_position"] = strafeDirection
		animator["parameters/Pistol/Combat/blend_position"] = strafeDirection
		animator["parameters/Pistol/Hunt/blend_position"] = strafeDirection

func Poles(_delta):

	if velocity == Vector3.ZERO:
		poles.rotation.y = 0.0

	else:
		if AISpawner.inversePoles:
			poles.global_rotation.y = atan2(velocity.x, velocity.z) + deg_to_rad(180)
		else:
			poles.global_rotation.y = atan2(velocity.x, velocity.z)



func Spine(delta):

	if currentState == State.Defend || currentState == State.Combat || currentState == State.Hunt || currentState == State.Attack:
		spineWeight = move_toward(spineWeight, spineData.weight, delta)
	else:
		spineWeight = move_toward(spineWeight, 0.0, delta * 10.0)


	var spinePose: Transform3D = skeleton.get_bone_global_pose_no_override(spineData.bone)
	var spineAimPose = spinePose.looking_at( - skeleton.to_local(LKL) + Vector3(0, 1, 0), Vector3.UP)
	spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.x, deg_to_rad(spineTarget.x))
	spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.y, deg_to_rad(spineTarget.y))
	spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.z, deg_to_rad(spineTarget.z))


	skeleton.set_bone_global_pose_override(spineData.bone, spineAimPose, spineWeight, true)

func Aim(delta):

	if impulseTimer < impulseTime:
		impulseTimer += delta
		spineTarget = lerp(spineTarget, impulseTarget, delta / impulseTime)

	else:

		if recoveryTimer < recoveryTime:
			recoveryTimer += delta
			aimSpeed = impulseTime

		else:
			aimSpeed = 1.0
			impact = false


		if animator["parameters/conditions/Rifle"]:

			if currentState == State.Defend:
				spineTarget = lerp(spineTarget, spineData.rifleDefend, delta / aimSpeed)

			elif currentState == State.Combat:
				if north:
					spineTarget = lerp(spineTarget, spineData.rifleCombatN, delta / aimSpeed)
				elif south:
					spineTarget = lerp(spineTarget, spineData.rifleCombatS, delta / aimSpeed)

			elif currentState == State.Hunt:
				if north:
					spineTarget = lerp(spineTarget, spineData.rifleHuntN, delta / aimSpeed)
				elif south:
					spineTarget = lerp(spineTarget, spineData.rifleHuntS, delta / aimSpeed)

			elif currentState == State.Attack:
				spineTarget = lerp(spineTarget, spineData.rifleAttackN, delta / aimSpeed)


		elif animator["parameters/conditions/Pistol"]:

			if currentState == State.Defend:
				spineTarget = lerp(spineTarget, spineData.pistolDefend, delta / aimSpeed)

			elif currentState == State.Combat:
				if north:
					spineTarget = lerp(spineTarget, spineData.pistolCombatN, delta / aimSpeed)
				elif south:
					spineTarget = lerp(spineTarget, spineData.pistolCombatS, delta / aimSpeed)

			elif currentState == State.Hunt:
				if north:
					spineTarget = lerp(spineTarget, spineData.pistolHuntN, delta / aimSpeed)
				elif south:
					spineTarget = lerp(spineTarget, spineData.pistolHuntS, delta / aimSpeed)

			elif currentState == State.Attack:
				spineTarget = lerp(spineTarget, spineData.pistolAttackN, delta / aimSpeed)



func ChangeState(state):
	match state:
		"Idle":
			speed = 0.0
			turnSpeed = 1.0
			movementVelocity = 1.0
			currentState = State.Idle
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
		"Group":
			speed = 0.0
			turnSpeed = 1.0
			movementVelocity = 1.0
			currentState = State.Group
			animator["parameters/Rifle/conditions/Group"] = true
			animator["parameters/Pistol/conditions/Group"] = true
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false

			var groupAnimation = randi_range(0, 2)
			animator["parameters/Rifle/Group/blend_position"] = groupAnimation
			ResetLKL()
		"Guard":
			speed = 0.0
			turnSpeed = 1.0
			movementVelocity = 1.0
			guardTimer = 0.0
			guardCycle = randf_range(4, 20)
			currentState = State.Guard
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = true
			animator["parameters/Pistol/conditions/Guard"] = true
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
			ResetLKL()
		"Patrol":
			if GetPatrolPoint():
				speed = 1.0
				turnSpeed = 5.0
				movementVelocity = 5.0
				currentState = State.Patrol
				animator["parameters/Rifle/conditions/Group"] = false
				animator["parameters/Pistol/conditions/Group"] = false
				animator["parameters/Rifle/conditions/Movement"] = true
				animator["parameters/Pistol/conditions/Movement"] = true
				animator["parameters/Rifle/conditions/Guard"] = false
				animator["parameters/Pistol/conditions/Guard"] = false
				animator["parameters/Rifle/conditions/Defend"] = false
				animator["parameters/Pistol/conditions/Defend"] = false
				animator["parameters/Rifle/conditions/Combat"] = false
				animator["parameters/Pistol/conditions/Combat"] = false
				animator["parameters/Rifle/conditions/Hunt"] = false
				animator["parameters/Pistol/conditions/Hunt"] = false
				animator["parameters/Rifle/conditions/Attack"] = false
				animator["parameters/Pistol/conditions/Attack"] = false
			else:
				print("No available patrol points")
				ChangeState("Wander")
		"Vantage":
			if GetVantagePoint():
				speed = 5.0
				turnSpeed = 5.0
				movementVelocity = 8.0
				currentState = State.Vantage
				animator["parameters/Rifle/conditions/Group"] = false
				animator["parameters/Pistol/conditions/Group"] = false
				animator["parameters/Rifle/conditions/Movement"] = true
				animator["parameters/Pistol/conditions/Movement"] = true
				animator["parameters/Rifle/conditions/Guard"] = false
				animator["parameters/Pistol/conditions/Guard"] = false
				animator["parameters/Rifle/conditions/Defend"] = false
				animator["parameters/Pistol/conditions/Defend"] = false
				animator["parameters/Rifle/conditions/Combat"] = false
				animator["parameters/Pistol/conditions/Combat"] = false
				animator["parameters/Rifle/conditions/Hunt"] = false
				animator["parameters/Pistol/conditions/Hunt"] = false
				animator["parameters/Rifle/conditions/Attack"] = false
				animator["parameters/Pistol/conditions/Attack"] = false
			else:
				print("No available vantage points")
				ChangeState("Combat")
		"Cover":
			if GetCoverPoint():
				speed = 5.0
				turnSpeed = 5.0
				movementVelocity = 8.0
				currentState = State.Cover
				animator["parameters/Rifle/conditions/Group"] = false
				animator["parameters/Pistol/conditions/Group"] = false
				animator["parameters/Rifle/conditions/Movement"] = true
				animator["parameters/Pistol/conditions/Movement"] = true
				animator["parameters/Rifle/conditions/Guard"] = false
				animator["parameters/Pistol/conditions/Guard"] = false
				animator["parameters/Rifle/conditions/Defend"] = false
				animator["parameters/Pistol/conditions/Defend"] = false
				animator["parameters/Rifle/conditions/Combat"] = false
				animator["parameters/Pistol/conditions/Combat"] = false
				animator["parameters/Rifle/conditions/Hunt"] = false
				animator["parameters/Pistol/conditions/Hunt"] = false
				animator["parameters/Rifle/conditions/Attack"] = false
				animator["parameters/Pistol/conditions/Attack"] = false
			else:
				print("No available cover points")
				ChangeState("Combat")
		"Hide":
			if GetHidePoint():
				speed = 5.0
				turnSpeed = 5.0
				movementVelocity = 8.0
				currentState = State.Hide
				animator["parameters/Rifle/conditions/Group"] = false
				animator["parameters/Pistol/conditions/Group"] = false
				animator["parameters/Rifle/conditions/Movement"] = true
				animator["parameters/Pistol/conditions/Movement"] = true
				animator["parameters/Rifle/conditions/Guard"] = false
				animator["parameters/Pistol/conditions/Guard"] = false
				animator["parameters/Rifle/conditions/Defend"] = false
				animator["parameters/Pistol/conditions/Defend"] = false
				animator["parameters/Rifle/conditions/Combat"] = false
				animator["parameters/Pistol/conditions/Combat"] = false
				animator["parameters/Rifle/conditions/Hunt"] = false
				animator["parameters/Pistol/conditions/Hunt"] = false
				animator["parameters/Rifle/conditions/Attack"] = false
				animator["parameters/Pistol/conditions/Attack"] = false
			else:
				print("No available hide points")
				ChangeState("Combat")
		"Evade":
			if GetEvadePoint():
				speed = 5.0
				turnSpeed = 5.0
				movementVelocity = 8.0
				currentState = State.Evade
				animator["parameters/Rifle/conditions/Group"] = false
				animator["parameters/Pistol/conditions/Group"] = false
				animator["parameters/Rifle/conditions/Movement"] = true
				animator["parameters/Pistol/conditions/Movement"] = true
				animator["parameters/Rifle/conditions/Guard"] = false
				animator["parameters/Pistol/conditions/Guard"] = false
				animator["parameters/Rifle/conditions/Defend"] = false
				animator["parameters/Pistol/conditions/Defend"] = false
				animator["parameters/Rifle/conditions/Combat"] = false
				animator["parameters/Pistol/conditions/Combat"] = false
				animator["parameters/Rifle/conditions/Hunt"] = false
				animator["parameters/Pistol/conditions/Hunt"] = false
				animator["parameters/Rifle/conditions/Attack"] = false
				animator["parameters/Pistol/conditions/Attack"] = false
			else:
				print("No available evade points")
				ChangeState("Combat")
		"Ambush":
			speed = 0.0
			turnSpeed = 1.0
			movementVelocity = 2.0
			ambushTimer = 0.0
			ambushCycle = randf_range(120, 360)
			currentState = State.Ambush
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = true
			animator["parameters/Pistol/conditions/Hunt"] = true
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
			ResetLKL()
		"Defend":
			speed = 0.0
			turnSpeed = 10.0
			movementVelocity = 1.0
			defendTimer = 0.0
			defendCycle = randf_range(4, 10)
			currentState = State.Defend
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = true
			animator["parameters/Pistol/conditions/Defend"] = true
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
		"Wander":
			GetWanderWaypoint()
			speed = 1.0
			turnSpeed = 5.0
			movementVelocity = 5.0
			currentState = State.Wander
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = true
			animator["parameters/Pistol/conditions/Movement"] = true
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
		"Combat":
			GetCombatWaypoint()
			speed = 1.0
			turnSpeed = 4.0
			movementVelocity = 5.0
			combatTimer = 0.0
			combatCycle = randf_range(4, 10)
			currentState = State.Combat
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = true
			animator["parameters/Pistol/conditions/Combat"] = true
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
		"Shift":
			GetShiftWaypoint()
			speed = 3.0
			turnSpeed = 10.0
			movementVelocity = 5.0
			shiftTimer = 0.0
			shiftCycle = randf_range(10, 20)
			currentState = State.Shift
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = true
			animator["parameters/Pistol/conditions/Attack"] = true
		"Hunt":
			GetAttackWaypoint()
			speed = 1.0
			turnSpeed = 4.0
			movementVelocity = 4.0
			huntTimer = 0.0
			huntCycle = 1.0
			currentState = State.Hunt
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = false
			animator["parameters/Pistol/conditions/Movement"] = false
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = true
			animator["parameters/Pistol/conditions/Hunt"] = true
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false
		"Attack":
			GetAttackWaypoint()
			speed = 3.0
			turnSpeed = 10.0
			movementVelocity = 8.0
			attackTimer = 0.0
			attackCycle = 1.0
			currentState = State.Attack
			animator["parameters/Rifle/conditions/Group"] = false
			animator["parameters/Pistol/conditions/Group"] = false
			animator["parameters/Rifle/conditions/Movement"] = true
			animator["parameters/Pistol/conditions/Movement"] = true
			animator["parameters/Rifle/conditions/Guard"] = false
			animator["parameters/Pistol/conditions/Guard"] = false
			animator["parameters/Rifle/conditions/Defend"] = false
			animator["parameters/Pistol/conditions/Defend"] = false
			animator["parameters/Rifle/conditions/Combat"] = false
			animator["parameters/Pistol/conditions/Combat"] = false
			animator["parameters/Rifle/conditions/Hunt"] = false
			animator["parameters/Pistol/conditions/Hunt"] = false
			animator["parameters/Rifle/conditions/Attack"] = false
			animator["parameters/Pistol/conditions/Attack"] = false

func States(delta):
	if currentState == State.Guard:
		Guard(delta)
	if currentState == State.Patrol:
		Patrol(delta)
	if currentState == State.Cover:
		Cover(delta)
	if currentState == State.Vantage:
		Vantage(delta)
	if currentState == State.Hide:
		Hide(delta)
	if currentState == State.Ambush:
		Ambush(delta)
	if currentState == State.Evade:
		Evade(delta)
	if currentState == State.Defend:
		Defend(delta)
	if currentState == State.Wander:
		Wander(delta)
	if currentState == State.Combat:
		Combat(delta)
	if currentState == State.Shift:
		Shift(delta)
	if currentState == State.Hunt:
		Hunt(delta)
	if currentState == State.Attack:
		Attack(delta)



func Decision():
	if AISpawner.forceCombat:
		ChangeState("Combat")
		combatCycle = 1000
		return

	if AISpawner.forceDefend:
		ChangeState("Defend")
		defendCycle = 1000
		return

	if AISpawner.forceHunt:
		ChangeState("Hunt")
		return

	if AISpawner.forceAttack:
		ChangeState("Attack")
		return


	if playerDistance3D > 20:
		var decision = randi_range(1, 8)

		if decision == 1:
			ChangeState("Combat")
		elif decision == 2 && !AISpawner.noHiding:
			ChangeState("Hide")
		elif decision == 3:
			ChangeState("Evade")
		elif decision == 4:
			ChangeState("Cover")
		elif decision == 5:
			ChangeState("Vantage")
		elif decision == 6:
			ChangeState("Defend")
		elif decision == 7 && playerVisible && playerDistance3D < 100 && !gameData.isTrading:
			ChangeState("Hunt")
		elif decision == 8 && playerVisible && playerDistance3D < 100 && !gameData.isTrading && (weaponData.action == 0 || weaponData.action == 1):
			ChangeState("Attack")
		else:
			ChangeState("Combat")


	else:
		var decision = randi_range(1, 4)

		if decision == 1:
			ChangeState("Combat")
		elif decision == 2:
			ChangeState("Defend")
		elif decision == 3 && playerVisible && !gameData.isTrading:
			ChangeState("Hunt")
		elif decision == 4 && playerVisible && !gameData.isTrading && (weaponData.action == 0 || weaponData.action == 1):
			ChangeState("Attack")
		else:
			ChangeState("Combat")

func Guard(delta):
	guardTimer += delta

	if guardTimer > guardCycle:
		ChangeState("Patrol")

func Patrol(_delta):
	if agent.is_target_reached():
		ChangeState("Guard")

	if global_transform.origin.distance_to(agent.target_position) < 2.0:
		speed = 1.0
		turnSpeed = 1.0

func Defend(delta):
	defendTimer += delta

	if playerVisible:
		Fire(delta)

	if defendTimer > defendCycle:
		ChangeState("Combat")

func Ambush(delta):
	ambushTimer += delta

	if ambushTimer > ambushCycle:
		ChangeState("Wander")

func Hide(_delta):

	if playerDistance3D < 10:
		ChangeState("Combat")


	if agent.is_target_reached():
		ChangeState("Ambush")


	if global_transform.origin.distance_to(agent.target_position) < 2.0:
		speed = 1.0
		turnSpeed = 2.0
	elif global_transform.origin.distance_to(agent.target_position) < 4.0:
		speed = 3.0
		turnSpeed = 5.0

func Cover(_delta):

	if playerDistance3D < 10:
		ChangeState("Combat")


	if agent.is_target_reached():
		ChangeState("Combat")


	if global_transform.origin.distance_to(agent.target_position) < 2.0:
		speed = 1.0
		turnSpeed = 2.0
	elif global_transform.origin.distance_to(agent.target_position) < 4.0:
		speed = 3.0
		turnSpeed = 5.0

func Vantage(_delta):

	if playerDistance3D < 10:
		ChangeState("Combat")


	if agent.is_target_reached():
		ChangeState("Defend")


	if global_transform.origin.distance_to(agent.target_position) < 2.0:
		speed = 1.0
		turnSpeed = 2.0
	elif global_transform.origin.distance_to(agent.target_position) < 4.0:
		speed = 3.0
		turnSpeed = 5.0

func Evade(_delta):

	if playerDistance3D < 10:
		ChangeState("Combat")


	if agent.is_target_reached():
		ChangeState("Combat")


	if global_transform.origin.distance_to(agent.target_position) < 2.0:
		speed = 1.0
		turnSpeed = 2.0
	elif global_transform.origin.distance_to(agent.target_position) < 4.0:
		speed = 3.0
		turnSpeed = 5.0

func Wander(_delta):

	if agent.is_target_reached():
		GetWanderWaypoint()

func Combat(delta):
	combatTimer += delta

	if playerVisible:
		Fire(delta)

	if combatTimer > combatCycle:
		Decision()

	if agent.is_target_reached():
		Decision()

func Shift(delta):
	shiftTimer += delta

	if playerVisible:
		Fire(delta)

	if shiftTimer > shiftCycle:
		ChangeState("Combat")

	if agent.is_target_reached():
		ChangeState("Combat")

func Hunt(delta):
	huntTimer += delta

	if playerVisible:
		Fire(delta)

	if huntTimer > huntCycle:
		GetHuntWaypoint()
		huntTimer = 0.0

	if agent.is_target_reached() || gameData.isTrading:
		ChangeState("Combat")

func Attack(delta):
	attackTimer += delta

	if playerVisible:
		Fire(delta)

	if attackTimer > attackCycle:
		GetAttackWaypoint()
		attackTimer = 0.0

	if agent.is_target_reached() || gameData.isTrading:
		ChangeState("Combat")



func Fire(delta):
	if impact || gameData.isTrading || AISpawner.fireBlocked:
		return


	if LKL.distance_to(playerPosition) > 4.0:
		return

	if weaponData.action == 0:
		Selector(delta)

	fireTime -= delta

	if fireTime <= 0:
		Raycast()
		PlayFireAudio()
		PlayTailAudio()
		MuzzleVFX()


		impulseTime = spineData.impulse / 2
		impulseTimer = 0.0


		recoveryTime = spineData.impulse
		recoveryTimer = 0.0


		if fullAuto:
			var impulseX = spineTarget.x - spineData.recoil / 10.0
			var impulseY = spineTarget.y
			var impulseZ = spineTarget.z
			impulseTarget = Vector3(impulseX, impulseY, impulseZ)
		else:
			var impulseX = spineTarget.x - spineData.recoil
			var impulseY = spineTarget.y
			var impulseZ = spineTarget.z
			impulseTarget = Vector3(impulseX, impulseY, impulseZ)

		muzzleFlash = true

		FireFrequency()
		await get_tree().create_timer(0.2).timeout;
		PlayCrackAudio()

func Selector(delta):
	selectorTime -= delta


	if selectorTime <= 0:

		if currentState == State.Attack:
			selectorRoll = 0

		else:
			selectorRoll = randi_range(0, 100)


		if selectorRoll <= 10 && !fullAuto:
			selectorTime = randf_range(1.0, 2.0)
			fullAuto = true
		else:
			selectorTime = randf_range(1.0, 5.0)
			fullAuto = false

func Raycast():
	fire.look_at(FireAccuracy(), Vector3.UP, true)
	fire.force_raycast_update()

	if fire.is_colliding():
		var collider = fire.get_collider()

		if collider.name == "Controller" && !gameData.isCaching:
			if AISpawner.damageBlocked:
				return

			collider.get_child(0).WeaponDamage(weaponData.damage, weaponData.penetration)
		else:
			var hitCollider = fire.get_collider()
			var hitPoint = fire.get_collision_point()
			var hitNormal = fire.get_collision_normal()
			var hitSurface = fire.get_collider().get("surfaceType")

			BulletDecal(hitCollider, hitPoint, hitNormal, hitSurface)
			PlayFlybyAudio()
	else:
		PlayFlybyAudio()

func FireFrequency():

	if weaponData.action == 0 && fullAuto:
		fireTime = weaponData.fireRate


	elif weaponData.action == 0 && !fullAuto:
		if playerDistance3D < 10:
			fireTime = randf_range(0.1, 0.5)
		elif playerDistance3D > 10 && playerDistance3D < 50:
			fireTime = randf_range(0.1, 1.0)
		else:
			fireTime = randf_range(0.1, 4.0)


	elif weaponData.action == 1:
		if playerDistance3D < 10:
			fireTime = randf_range(0.1, 0.5)
		elif playerDistance3D > 10 && playerDistance3D < 50:
			fireTime = randf_range(0.1, 1.0)
		else:
			fireTime = randf_range(0.1, 4.0)


	elif weaponData.action == 2 || weaponData.action == 3:
		if playerDistance3D < 10:
			fireTime = randf_range(1.0, 2.0)
		elif playerDistance3D > 10 && playerDistance3D < 50:
			fireTime = randf_range(1.0, 2.0)
		else:
			fireTime = randf_range(1.0, 4.0)

func FireAccuracy() -> Vector3:
	var fireDirection = playerPosition + Vector3(0, 1.0, 0)
	var spreadMultiplier = 1.0

	if fullAuto:
		spreadMultiplier = 2.0


	if playerDistance3D < 10:
		fireDirection.x += randf_range(-0.1, 0.1) * spreadMultiplier
		fireDirection.y += randf_range(-0.1, 0.1) * spreadMultiplier

	elif playerDistance3D > 10 && playerDistance3D < 50:
		fireDirection.x += randf_range(-1.0, 1.0) * spreadMultiplier
		fireDirection.y += randf_range(-1.0, 1.0) * spreadMultiplier

	else:
		fireDirection.x += randf_range(-2.0, 2.0) * spreadMultiplier
		fireDirection.y += randf_range(-2.0, 2.0) * spreadMultiplier

	return fireDirection



func BulletDecal(hitCollider, hitPoint, hitNormal, hitSurface):
	var bulletDecal = hit.instantiate()
	hitCollider.add_child(bulletDecal)
	bulletDecal.global_transform.origin = hitPoint

	var surfaceDirUp = Vector3(0, 1, 0)
	var surfaceDirDown = Vector3(0, -1, 0)

	if hitNormal == surfaceDirUp:
		bulletDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
	elif hitNormal == surfaceDirDown:
		bulletDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
	else:
		bulletDecal.look_at(hitPoint + hitNormal, Vector3.DOWN)

	bulletDecal.global_rotation.z = randf_range(-360, 360)

	bulletDecal.PlayHit(hitSurface)

func MuzzleFlash(delta):

	if muzzle:
		light.global_transform = muzzle.global_transform

	if muzzleFlash:
		flashTimer += delta

		if gameData.TOD == 2:
			light.light_energy = 0.4
			light.omni_range = 5.0
		else:
			light.light_energy = 0.4
			light.omni_range = 5.0

		if flashTimer > 0.05:
			light.omni_range = 0.0
			light.light_energy = 0.0
			flashTimer = 0.0
			muzzleFlash = false

func MuzzleVFX():
	var newFlashLarge = flashLarge.instantiate()
	muzzle.add_child(newFlashLarge)
	newFlashLarge.Emit()

	var newSmoke = smoke.instantiate()
	muzzle.add_child(newSmoke)
	newSmoke.Emit()



func TakeDamage(hitbox: String, damage: float):
	if dead:
		return


	if !AISpawner.infiniteHealth:
		health -= damage


	impact = true
	impulseTime = spineData.impulse
	impulseTimer = 0.0


	recoveryTime = spineData.impulse
	recoveryTimer = 0.0


	if hitbox == "Head" || hitbox == "Torso":
		var impulseX = randf_range(spineTarget.x - spineData.impact / 2, spineTarget.x - spineData.impact)
		var impulseY = randf_range(spineTarget.y - spineData.impact, spineTarget.y + spineData.impact)
		var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
		impulseTarget = Vector3(impulseX, impulseY, impulseZ)
	elif hitbox == "Leg_L":
		var impulseX = randf_range(spineTarget.x + spineData.impact / 2, spineTarget.x + spineData.impact)
		var impulseY = randf_range(spineTarget.y + spineData.impact / 2, spineTarget.y + spineData.impact)
		var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
		impulseTarget = Vector3(impulseX, impulseY, impulseZ)
	elif hitbox == "Leg_R":
		var impulseX = randf_range(spineTarget.x + spineData.impact / 2, spineTarget.x + spineData.impact)
		var impulseY = randf_range(spineTarget.y - spineData.impact / 2, spineTarget.y - spineData.impact)
		var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
		impulseTarget = Vector3(impulseX, impulseY, impulseZ)

	if health <= 0:
		Death()



func GetPatrolPoint() -> bool:
	var availablePoints: Array[Node3D]
	var target = Node3D
	var available = false


	if patrols.get_child_count() != 0:

		for point in patrols.get_children():

			if point.area == currentArea && point.name != currentPoint.name:

				availablePoints.append(point)
				available = true

	if available:

		var randomIndex = randi_range(0, availablePoints.size() - 1)
		target = availablePoints[randomIndex]

		currentPoint = target
		currentArea = target.area

		MoveToPosition(target.global_position)
		return true
	else:
		return false

func GetHidePoint() -> bool:
	var availablePoints: Array[Node3D]
	var target: Node3D
	var available = false


	if hides.get_child_count() != 0:

		for point in hides.get_children():
			var distanceToAI = global_transform.origin.distance_to(point.global_position)
			var distanceToPlayer = point.global_position.distance_to(playerPosition)


			if distanceToAI < 40 && distanceToAI < distanceToPlayer && point.name != currentPoint.name:
				availablePoints.append(point)
				available = true

	if available:

		var randomIndex = randi_range(0, availablePoints.size() - 1)
		target = availablePoints[randomIndex]

		currentPoint = target

		MoveToPosition(target.global_position)
		return true
	else:
		return false

func GetVantagePoint() -> bool:
	var threshold = -1000
	var target: Node3D
	var available = false


	if patrols.get_child_count() != 0:

		for point in patrols.get_children():
			var distanceToAI = global_transform.origin.distance_to(point.global_position)
			var distantoToPlayer = point.global_transform.origin.distance_to(playerPosition)


			if distanceToAI < 40 && distanceToAI < distantoToPlayer && point.name != currentPoint.name:
				var direction = (playerPosition - point.global_position).normalized()
				var vector = direction.dot(point.transform.basis.z)


				if vector > threshold:

					threshold = vector

					target = point
					available = true

	if available:

		currentPoint = target

		MoveToPosition(target.global_position)
		return true
	else:
		return false

func GetCoverPoint() -> bool:
	var threshold = 1000
	var target: Node3D
	var available = false


	if covers.get_child_count() != 0:

		for cover in covers.get_children():
			var distanceToAI = global_transform.origin.distance_to(cover.global_position)
			var distantoToPlayer = cover.global_transform.origin.distance_to(playerPosition)


			if distanceToAI < 40 && distanceToAI < distantoToPlayer:
				var direction = (playerPosition - cover.global_position).normalized()
				var vector = direction.dot(cover.transform.basis.z)


				if vector < threshold:

					threshold = vector

					target = cover
					available = true

	if available:

		currentPoint = target

		MoveToPosition(target.global_position)
		return true
	else:
		return false

func GetEvadePoint() -> bool:
	var target: Node3D
	var available = false

	var overlaps = evader.get_overlapping_areas()


	if overlaps.size() > 0:

		for overlap in overlaps:
			var distance = overlap.global_transform.origin.distance_to(global_position)


			if distance > 20.0:
				target = overlap
				available = true

	if available:
		MoveToPosition(target.global_position)
		return true
	else:
		return false

func GetWanderWaypoint():
	var randomWaypoint = waypoints.get_child(randi_range(0, waypoints.get_child_count() - 1))
	MoveToPosition(randomWaypoint.global_position)

func GetCombatWaypoint():
	var randomWaypoint = waypoints.get_child(randi_range(0, waypoints.get_child_count() - 1))
	MoveToPosition(randomWaypoint.global_position)

func GetShiftWaypoint():
	var randomWaypoint = waypoints.get_child(randi_range(0, waypoints.get_child_count() - 1))
	MoveToPosition(randomWaypoint.global_position)

func GetHuntWaypoint():
	MoveToPosition(lastKnownLocation)

func GetAttackWaypoint():
	MoveToPosition(lastKnownLocation)

func MoveToPosition(origin: Vector3):
	var closestPosition = NavigationServer3D.map_get_closest_point(navigationMap, origin)
	agent.target_position = closestPosition

func GetClosestPoint(points: Node3D) -> Node3D:
	var minimumDistance = 1000
	var closestPoint: Node3D


	for point in points.get_children():

		var distance = global_position.distance_to(point.global_position)


		if distance < minimumDistance:

			minimumDistance = distance

			closestPoint = point

	return closestPoint

func GetHighestVector(points: Node3D) -> Node3D:
	var minimumVector = -1000
	var highestVector: Node3D


	for point in points.get_children():

		var direction = (playerPosition - point.global_position).normalized()
		var vector = direction.dot(point.transform.basis.z)


		if vector > minimumVector:

			minimumVector = vector

			highestVector = point

	return highestVector

func GetLowestVector(points: Node3D) -> Node3D:
	var minimumVector = 1000
	var lowestVector: Node3D


	for point in points.get_children():

		var direction = (playerPosition - point.global_position).normalized()
		var vector = direction.dot(point.transform.basis.z)


		if vector < minimumVector:

			minimumVector = vector

			lowestVector = point

	return lowestVector

func GetNearestPole():
	var minimumDistance = 1000
	var closestPoint: Node3D


	north = false
	south = false
	north1 = false
	north2 = false
	south1 = false
	south2 = false


	for point in poles.get_children():

		var distance = LKL.distance_to(point.global_position)


		if distance < minimumDistance:

			minimumDistance = distance

			closestPoint = point

	return closestPoint

func UpdateGizmos():
	if playerVisible:
		gizmo.material.albedo_color = Color.RED
	else:
		gizmo.material.albedo_color = Color.GREEN

func ShowGizmos():
	agent.debug_enabled = true
	gizmo.show()
	poles.show()

func HideGizmos():
	agent.debug_enabled = false
	gizmo.hide()
	poles.hide()

func ResetLKL():
	lastKnownLocation = currentPoint.global_position + Vector3(0, 1, 0) + currentPoint.basis.z * 2.0
	fireTime = 0.2



func PlayFootstep():
	if below.is_colliding():
		var surface
		var collisionSurface = below.get_collider().get("surfaceType")
		var footstepAudio = audioInstance3D.instantiate()
		add_child(footstepAudio)

		var loudness: float


		if currentState == State.Hunt:
			loudness = 2
		elif movementSpeed < 2:
			loudness = 4
		else:
			loudness = 8


		if collisionSurface == 0:
			surface = 0

		elif collisionSurface == 1:
			surface = 1

		elif collisionSurface == 2:
			surface = 2

		elif collisionSurface == 3:
			surface = 3

		elif collisionSurface == 4:
			surface = 4

		elif collisionSurface == 5:
			surface = 5

		elif collisionSurface == 6:
			surface = 6

		elif collisionSurface == 7:
			surface = 7
		else:
			surface = 7

		if gameData.season == 1:
			if surface == 1:
				footstepAudio.PlayInstance(audioLibrary.footstepGrass, loudness, 50)
			elif surface == 2:
				footstepAudio.PlayInstance(audioLibrary.footstepDirt, loudness, 50)
			elif surface == 3:
				footstepAudio.PlayInstance(audioLibrary.footstepAsphalt, loudness, 50)
			elif surface == 4:
				footstepAudio.PlayInstance(audioLibrary.footstepRock, loudness, 50)
			elif surface == 5:
				footstepAudio.PlayInstance(audioLibrary.footstepWood, loudness, 50)
			elif surface == 6:
				footstepAudio.PlayInstance(audioLibrary.footstepMetal, loudness, 50)
			elif surface == 7:
				footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)
			else:
				footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)

		elif gameData.season == 2:
			if surface == 1:
				footstepAudio.PlayInstance(audioLibrary.footstepSnowHard, loudness, 50)
			elif surface == 2:
				footstepAudio.PlayInstance(audioLibrary.footstepSnowHard, loudness, 50)
			elif surface == 3:
				footstepAudio.PlayInstance(audioLibrary.footstepAsphalt, loudness, 50)
			elif surface == 4:
				footstepAudio.PlayInstance(audioLibrary.footstepRock, loudness, 50)
			elif surface == 5:
				footstepAudio.PlayInstance(audioLibrary.footstepWood, loudness, 50)
			elif surface == 6:
				footstepAudio.PlayInstance(audioLibrary.footstepMetal, loudness, 50)
			elif surface == 7:
				footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)
			else:
				footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)

func PlayHeadlampAudio():
	var headlampAudio = audioInstance3D.instantiate()
	headlamp.add_child(headlampAudio)
	headlampAudio.PlayInstance(audioLibrary.flashlight, 5, 50)

func PlayFireAudio():

	if weaponData.action == 0 && fullAuto:
		var fireAudio = audioInstance3D.instantiate()
		add_child(fireAudio)
		fireAudio.PlayInstance(weaponData.fireAuto, 50, 200)

	else:
		var fireAudio = audioInstance3D.instantiate()
		add_child(fireAudio)
		fireAudio.PlayInstance(weaponData.fireSemi, 50, 200)

func PlayTailAudio():
	var tailAudio = audioInstance3D.instantiate()
	add_child(tailAudio)
	tailAudio.PlayInstance(weaponData.tailOutdoor, 50, 400)

func PlayFlybyAudio():
	var flyby = audioInstance2D.instantiate()
	add_child(flyby)
	flyby.PlayInstance(audioLibrary.supersonic)

func PlayCrackAudio():
	var crackRoll = randi_range(0, 100)

	if crackRoll < 50 && crackRoll > 25:
		PlayCrackMedium()
	elif crackRoll < 25:
		PlayCrackHeavy()

func PlayDistantNear():
	var distantNearAudio = audioInstance3D.instantiate()
	add_child(distantNearAudio)
	distantNearAudio.PlayInstance(weaponData.distantNear, 100, 2000)

func PlayDistantFar():
	var distantFarAudio = audioInstance3D.instantiate()
	add_child(distantFarAudio)
	distantFarAudio.PlayInstance(weaponData.distantFar, 200, 2000)

func PlayCrackLight():
	var crackLight = audioInstance2D.instantiate()
	add_child(crackLight)
	crackLight.PlayInstance(audioLibrary.crackLight)

func PlayCrackMedium():
	var crackMedium = audioInstance2D.instantiate()
	add_child(crackMedium)
	crackMedium.PlayInstance(audioLibrary.crackMedium)

func PlayCrackHeavy():
	var crackHeavy = audioInstance2D.instantiate()
	add_child(crackHeavy)
	crackHeavy.PlayInstance(audioLibrary.crackHeavy)
