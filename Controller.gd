extends CharacterBody3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@export var developer = false


@onready var head = % Head
@onready var pelvis = $Pelvis
@onready var bob = % Bob
@onready var camera = % Camera
@onready var character = $Character
@onready var weapons = $"../Camera/Weapons"


@onready var standCollider = $Stand
@onready var crouchCollider = $Crouch


@onready var above = $Raycasts / Above
@onready var below = $Raycasts / Below
@onready var left = $Raycasts / Left
@onready var right = $Raycasts / Right


var currentSpeed = 0.0
var walkSpeed = 2.5
var sprintSpeed = 6.0
var crouchSpeed = 1.0
var swimSpeed = 2.0
var lerpSpeed = 5.0
var inertia = 1.0


const headbobWalkSpeed = 10.0
const headbobSprintSpeed = 20.0
const headbobCrouchSpeed = 8.0
const headbobSwimSpeed = 6.0
const headbobWalkIntensity = 0.02
const headbobSprintIntensity = 0.05
const headbobCrouchIntensity = 0.02
const headbobSwimIntensity = 0.02
var headbobIndex = 0.0
var headbobIntensity = 0.0
var headbobVector = Vector2.ZERO
var canStep = false


var mouseSensitivity = 0.1
var movementDirection = Vector3.ZERO
var inputDirection = Vector2.ZERO


var jumpVelocity = 7.0
var jumpControl = 8.0
var velocityMultiplier = 1.0
var gravityMultiplier = 2.0
var lastVelocity = Vector3.ZERO


var jumpImpulse = 0.0
var jumpImpulseTimer = 0.0
var landImpulse = 0.0
var landImpulseTimer = 0.0
var crouchImpulse = 0.0
var crouchImpulseTimer = 0.0
var standImpulse = 0.0
var standImpulseTimer = 0.0
var hasJumped = false
var hasLanded = true


var surface
var scanTimer = 0.0
var scanCycle = 0.2


var sprintToggle = false


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fallStartLevel = 0.0;
var fallThreshold = 5.0;

func _ready():
    if gameData.flycam:
        gravity = 0.0
        gameData.isFlying = true
        pelvis.position.y = 0.2
        standCollider.disabled = true
        crouchCollider.disabled = false
    else:
        gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
        gameData.isFlying = false
        pelvis.position.y = 1.0
        standCollider.disabled = false
        crouchCollider.disabled = true

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    lastVelocity.y = 0.0

func _input(event):
    if Input.is_action_just_pressed(("swim")):

        if !gameData.isSwimming && gameData.isWater:
            movementDirection = Vector3.ZERO
            lastVelocity = Vector3.ZERO

            gameData.isSwimming = true
            gameData.isWalking = false
            gameData.isRunning = false

            if gameData.primary || gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


        elif gameData.isSwimming:
            movementDirection = Vector3.ZERO
            lastVelocity = Vector3.ZERO

            gameData.isSwimming = false


    if event is InputEventKey:
        if event.pressed:
            if event.keycode == KEY_NUMLOCK && developer:

                gameData.isFlying = !gameData.isFlying

                if gameData.isFlying:
                    gravity = 0.0
                else:
                    gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

    if gameData.freeze || gameData.isCaching || gameData.isInspecting:
        return

    if event is InputEventMouseMotion && !gameData.freeze:
        if gameData.isAiming && gameData.isScoped:
            if gameData.mouseMode == 2:
                rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.scopeSensitivity, 0.1, 2.0) / 10))
                head.rotate_x(deg_to_rad(event.relative.y * clampf(gameData.scopeSensitivity, 0.1, 2.0) / 10))
                head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
            else:
                rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.scopeSensitivity, 0.1, 2.0) / 10))
                head.rotate_x(deg_to_rad( - event.relative.y * clampf(gameData.scopeSensitivity, 0.1, 2.0) / 10))
                head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
        else:
            if gameData.isAiming:
                if gameData.mouseMode == 2:
                    rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.aimSensitivity, 0.1, 2.0) / 10))
                    head.rotate_x(deg_to_rad(event.relative.y * clampf(gameData.aimSensitivity, 0.1, 2.0) / 10))
                    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
                else:
                    rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.aimSensitivity, 0.1, 2.0) / 10))
                    head.rotate_x(deg_to_rad( - event.relative.y * clampf(gameData.aimSensitivity, 0.1, 2.0) / 10))
                    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
            else:
                if gameData.mouseMode == 2:
                    rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.lookSensitivity, 0.1, 2.0) / 10))
                    head.rotate_x(deg_to_rad(event.relative.y * clampf(gameData.lookSensitivity, 0.1, 2.0) / 10))
                    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
                else:
                    rotate_y(deg_to_rad( - event.relative.x * clampf(gameData.lookSensitivity, 0.1, 2.0) / 10))
                    head.rotate_x(deg_to_rad( - event.relative.y * clampf(gameData.lookSensitivity, 0.1, 2.0) / 10))
                    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
    if gameData.isCaching:
        return

    if gameData.isFlying:
        Fly()
    elif gameData.isSwimming:
        Swim(delta)
        Headbob(delta)
    else:
        if gameData.isSubmerged:
            Sink(delta)
        else:
            SurfaceDetection(delta)
            Movement(delta)
            Inertia(delta)
            Gravity(delta)
            Falling()
            Landing(delta)
            Crouch(delta)
            Jump(delta)
            JumpImpulse(delta)
            LandImpulse(delta)
            CrouchImpulse(delta)
            StandImpulse(delta)
            Headbob(delta)
            MovementStates(delta)

    if gameData.freeze || gameData.isCaching:
        inputDirection = Vector2.ZERO
        currentSpeed = lerp(currentSpeed, 0.0, delta * 5.0)
        return

    InputDirection(delta)

func Sink(delta):

    gameData.isWalking = false
    gameData.isRunning = false


    if hasJumped:
        PlayFootstepLand()
        hasJumped = false

    movementDirection = lerp(movementDirection, (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta)

    if movementDirection:
        velocity.x = movementDirection.x
        velocity.z = movementDirection.z
    else:
        velocity.x = 0.0
        velocity.z = 0.0

    velocity.y = lerp(velocity.y, -1.0, delta * 4.0)

    lastVelocity = velocity
    move_and_slide()

func Movement(delta):
    gameData.playerPosition = global_transform.origin
    gameData.playerVector = camera.global_basis.z
    RenderingServer.global_shader_parameter_set("Player", global_transform.origin)


    if is_on_floor():
        gameData.isGrounded = true
        velocityMultiplier = 1.0
        movementDirection = lerp(movementDirection, (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta * lerpSpeed)

    else:
        gameData.isGrounded = false
        velocityMultiplier = 0.8
        if inputDirection != Vector2.ZERO:
            movementDirection = lerp(movementDirection, (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta * lerpSpeed / jumpControl)

    if movementDirection:
        if gameData.overweight || gameData.fracture:
            velocity.x = movementDirection.x * (currentSpeed / 1.5 * velocityMultiplier * inertia)
            velocity.z = movementDirection.z * (currentSpeed / 1.5 * velocityMultiplier * inertia)
        else:
            velocity.x = movementDirection.x * (currentSpeed * velocityMultiplier * inertia)
            velocity.z = movementDirection.z * (currentSpeed * velocityMultiplier * inertia)
    else:
        velocity.x = 0.0
        velocity.z = 0.0

    lastVelocity = velocity
    move_and_slide()

func Fly():
    gameData.playerPosition = global_transform.origin
    gameData.playerVector = camera.global_basis.z

    var flySpeed: float
    var heightVector: float
    gameData.isFalling = false
    fallStartLevel = global_position.y


    if Input.is_key_pressed(KEY_SHIFT):
        flySpeed = 50.0
    elif Input.is_key_pressed(KEY_CTRL):
        flySpeed = 0.5
    else:
        flySpeed = 2.0


    if Input.is_key_pressed(KEY_E):
        heightVector = 1.0
    if Input.is_key_pressed(KEY_Q):
        heightVector = -1.0


    velocity = camera.global_basis * Vector3(inputDirection.x, heightVector, inputDirection.y) * flySpeed


    if inputDirection == Vector2.ZERO && !Input.is_action_pressed("lean_L") && !Input.is_action_pressed("lean_R"):
        heightVector = 0.0
        velocity = Vector3.ZERO

    move_and_slide()

func Swim(delta):
    gameData.isFalling = false
    fallStartLevel = global_position.y

    standCollider.disabled = true
    crouchCollider.disabled = false
    pelvis.position.y = lerp(pelvis.position.y, 0.5, delta * 5.0)

    if gameData.overweight || gameData.fracture:
        swimSpeed = 1.0
    else:
        swimSpeed = 2.0

    if position.y > -3.0:
        position.y = lerp(position.y, -3.0, delta * 2.0)

    if head.rotation_degrees.x > 0 && position.y > -3.0:
        velocity = lerp(velocity, global_basis * Vector3(inputDirection.x, 0, inputDirection.y) * swimSpeed, delta)
    else:
        velocity = lerp(velocity, camera.global_basis * Vector3(inputDirection.x, 0, inputDirection.y) * swimSpeed, delta)


    if inputDirection == Vector2.ZERO:
        velocity = lerp(velocity, Vector3.ZERO, delta)
        gameData.isMoving = false
    else:
        gameData.isMoving = true

    move_and_slide()

func SurfaceDetection(delta):
    scanTimer += delta

    if scanTimer > scanCycle:

        if below.is_colliding():
            surface = below.get_collider().get("surfaceType")


            if surface == 0:
                gameData.surface = 0

            elif surface == 1:
                gameData.surface = 1

            elif surface == 2:
                gameData.surface = 2

            elif surface == 3:
                gameData.surface = 3

            elif surface == 4:
                gameData.surface = 4

            elif surface == 5:
                gameData.surface = 5

            elif surface == 6:
                gameData.surface = 6

            elif surface == 7:
                gameData.surface = 7
            else:
                gameData.surface = 7

        if left.is_colliding():
            gameData.leanLBlocked = true
        else:
            gameData.leanLBlocked = false

        if right.is_colliding():
            gameData.leanRBlocked = true
        else:
            gameData.leanRBlocked = false

        scanTimer = 0.0

func Inertia(delta):
    if gameData.isRunning:

        if inputDirection.y >= 0 && inputDirection.y < 0.5:
            inertia = lerp(inertia, 0.6, delta * 2.0)

        elif inputDirection.y > 0.5:
            inertia = lerp(inertia, 0.5, delta * 2.0)

        else:
            inertia = lerp(inertia, 1.0, delta * 2.0)
    else:
        inertia = lerp(inertia, 1.0, delta * 2.0)

func Landing(_delta):
    if is_on_floor():
        if lastVelocity.y < 0.0 && hasJumped:
            landImpulse = 0.1

            if !hasLanded:
                PlayFootstepLand()

            hasLanded = true
            hasJumped = false

func Gravity(delta):
    if !is_on_floor():
        velocity.y -= gravity * delta * gravityMultiplier

func Falling():
    if is_on_floor():
        if gameData.isFalling:
            gameData.isFalling = false


            if global_position.y < fallStartLevel - fallThreshold:
                character.FallDamage(fallStartLevel - global_position.y)
                print("FALL " + str(fallStartLevel - global_position.y))

                if !hasJumped:
                    hasJumped = true
                    hasLanded = false


            if global_position.y < fallStartLevel - 0.5:
                if !hasJumped:
                    hasJumped = true
                    hasLanded = false
    else:
        if !gameData.isFalling:
            gameData.isFalling = true
            fallStartLevel = global_position.y

func InputDirection(_delta):

    inputDirection = Input.get_vector("left", "right", "forward", "backward")
    gameData.inputDirection = inputDirection

func MovementStates(delta):

    if !gameData.isMoving:
        gameData.isIdle = true
    else:
        gameData.isIdle = false


    if inputDirection != Vector2.ZERO:
        gameData.isMoving = true


        if gameData.isCrouching:


            if gameData.sprintMode == 2 && Input.is_action_just_pressed("sprint"):
                sprintToggle = !sprintToggle

            gameData.isCrouching = true
            gameData.isWalking = false
            gameData.isRunning = false
            currentSpeed = lerp(currentSpeed, crouchSpeed, delta * 2.5)


        else:


            if gameData.sprintMode == 1:


                if Input.is_action_pressed("sprint"):
                    currentSpeed = lerp(currentSpeed, sprintSpeed, delta * 1.0)
                    gameData.isWalking = false
                    gameData.isRunning = true
                    gameData.isCrouching = false


                else:
                    currentSpeed = lerp(currentSpeed, walkSpeed, delta * 2.5)
                    gameData.isWalking = true
                    gameData.isRunning = false
                    gameData.isCrouching = false


            elif gameData.sprintMode == 2:


                if Input.is_action_just_pressed("sprint"):
                    sprintToggle = !sprintToggle


                if sprintToggle:
                    currentSpeed = lerp(currentSpeed, sprintSpeed, delta * 1.0)
                    gameData.isRunning = true
                    gameData.isWalking = false
                    gameData.isCrouching = false


                else:
                    currentSpeed = lerp(currentSpeed, walkSpeed, delta * 2.5)
                    gameData.isWalking = true
                    gameData.isRunning = false
                    gameData.isCrouching = false


    else:
        currentSpeed = lerp(currentSpeed, 0.0, delta * 5.0)
        gameData.isMoving = false
        gameData.isWalking = false
        gameData.isRunning = false


        if gameData.sprintMode == 2 && Input.is_action_just_pressed("sprint"):
            sprintToggle = !sprintToggle

func Crouch(delta):
    if Input.is_action_just_pressed("crouch") && is_on_floor() && !above.is_colliding() && !gameData.freeze:
        gameData.isCrouching = !gameData.isCrouching

        if gameData.isCrouching:
            crouchImpulse = 0.1
            standCollider.disabled = true
            crouchCollider.disabled = false
        else:
            standImpulse = 0.1
            standCollider.disabled = false
            crouchCollider.disabled = true

    if gameData.isCrouching:
        pelvis.position.y = lerp(pelvis.position.y, 0.5, delta * 5.0)
    else:
        pelvis.position.y = lerp(pelvis.position.y, 1.0, delta * 5.0)

func Jump(_delta):

    if Input.is_action_just_pressed("jump") and is_on_floor() && !gameData.isCrouching && !gameData.freeze:
        hasJumped = true
        hasLanded = false

        if gameData.bodyStamina > 0:
            gameData.bodyStamina -= 10

        if gameData.overweight || gameData.fracture:
            velocity.y = jumpVelocity / 1.2
        else:
            velocity.y = jumpVelocity

        jumpImpulse = 0.1
        PlayFootstepJump()

func Headbob(delta):

    if gameData.isWalking:
        headbobIntensity = headbobWalkIntensity * gameData.headbob
        headbobIndex += headbobWalkSpeed * delta
    elif gameData.isRunning:
        headbobIntensity = headbobSprintIntensity * gameData.headbob
        headbobIndex += headbobSprintSpeed * delta
    elif gameData.isCrouching:
        headbobIntensity = headbobCrouchIntensity * gameData.headbob
        headbobIndex += headbobCrouchSpeed * delta
    elif gameData.isSwimming:
        headbobIntensity = headbobSwimIntensity * gameData.headbob
        headbobIndex += headbobSwimSpeed * delta


    if (is_on_floor() || gameData.isSwimming) && inputDirection != Vector2.ZERO:
        headbobVector.x = sin(headbobIndex / 2)
        headbobVector.y = sin(headbobIndex)
        bob.position.x = lerp(bob.position.x, headbobVector.x * headbobIntensity, delta * lerpSpeed)
        bob.position.y = lerp(bob.position.y, headbobVector.y * (headbobIntensity * 2), delta * lerpSpeed)
    else:
        bob.position.x = lerp(bob.position.x, 0.0, delta * lerpSpeed)
        bob.position.y = lerp(bob.position.y, 0.0, delta * lerpSpeed)


    if headbobVector.y < -0.5 && !canStep:
        canStep = true
    if headbobVector.y > 0.5 && canStep:

        if gameData.isSwimming:
            if gameData.isSubmerged:
                PlaySwimSubmerged()
                canStep = false
            else:
                PlaySwimSurface()
                canStep = false
        else:
            PlayFootstep()
            canStep = false

func JumpImpulse(delta):
    if jumpImpulseTimer < jumpImpulse:
        gameData.jump = true
        jumpImpulseTimer += delta
    else:
        gameData.jump = false
        jumpImpulseTimer = 0.0
        jumpImpulse = 0.0

func LandImpulse(delta):
    if landImpulseTimer < landImpulse:
        gameData.land = true
        landImpulseTimer += delta
    else:
        gameData.land = false
        landImpulseTimer = 0.0
        landImpulse = 0.0

func CrouchImpulse(delta):
    if crouchImpulseTimer < crouchImpulse:
        gameData.crouch = true
        crouchImpulseTimer += delta
    else:
        gameData.crouch = false
        crouchImpulseTimer = 0.0
        crouchImpulse = 0.0

func StandImpulse(delta):
    if standImpulseTimer < standImpulse:
        gameData.stand = true
        standImpulseTimer += delta
    else:
        gameData.stand = false
        standImpulseTimer = 0.0
        standImpulse = 0.0

func PlayFootstep():
    var footstep = audioInstance2D.instantiate()
    add_child(footstep)

    PlayMovementCloth()

    if character.heavyGear:
        PlayMovementGear()

    if gameData.isWater:
        footstep.PlayInstance(audioLibrary.footstepWater)
    else:
        if gameData.season == 1:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepGrass)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepDirt)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphalt)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRock)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWood)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetal)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcrete)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcrete)

        elif gameData.season == 2:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepSnowHard)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepSnowHard)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphalt)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRock)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWood)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetal)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcrete)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcrete)

func PlayFootstepJump():
    var footstep = audioInstance2D.instantiate()
    add_child(footstep)

    PlayMovementCloth()

    if character.heavyGear:
        PlayMovementGear()

    if gameData.isWater:
        footstep.PlayInstance(audioLibrary.footstepWater)
    else:
        if gameData.season == 1:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepGrass)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepDirt)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphalt)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRock)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWood)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetal)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcrete)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcrete)

        elif gameData.season == 2:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepSnowHard)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepSnowHard)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphalt)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRock)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWood)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetal)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcrete)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcrete)

func PlayFootstepLand():
    var footstep = audioInstance2D.instantiate()
    add_child(footstep)

    PlayMovementCloth()

    if character.heavyGear:
        PlayMovementGear()

    if gameData.isWater:
        footstep.PlayInstance(audioLibrary.footstepWaterLand)
    else:
        if gameData.season == 1:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepGrassLand)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepDirtLand)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphaltLand)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRockLand)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWoodLand)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetalLand)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcreteLand)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcreteLand)

        elif gameData.season == 2:
            if gameData.surface == 1:
                footstep.PlayInstance(audioLibrary.footstepSnowHardLand)
            elif gameData.surface == 2:
                footstep.PlayInstance(audioLibrary.footstepSnowHardLand)
            elif gameData.surface == 3:
                footstep.PlayInstance(audioLibrary.footstepAsphaltLand)
            elif gameData.surface == 4:
                footstep.PlayInstance(audioLibrary.footstepRockLand)
            elif gameData.surface == 5:
                footstep.PlayInstance(audioLibrary.footstepWoodLand)
            elif gameData.surface == 6:
                footstep.PlayInstance(audioLibrary.footstepMetalLand)
            elif gameData.surface == 7:
                footstep.PlayInstance(audioLibrary.footstepConcreteLand)
            else:
                footstep.PlayInstance(audioLibrary.footstepConcreteLand)

func PlaySwimSurface():
    var swimSurface = audioInstance2D.instantiate()
    add_child(swimSurface)
    swimSurface.PlayInstance(audioLibrary.swimSurface)

func PlaySwimSubmerged():
    var swimSubmerged = audioInstance2D.instantiate()
    add_child(swimSubmerged)
    swimSubmerged.PlayInstance(audioLibrary.swimSubmerged)

func PlayMovementCloth():
    var movementCloth = audioInstance2D.instantiate()
    add_child(movementCloth)
    movementCloth.PlayInstance(audioLibrary.movementCloth)

func PlayMovementGear():
    var movementGear = audioInstance2D.instantiate()
    add_child(movementGear)
    movementGear.PlayInstance(audioLibrary.movementGear)
