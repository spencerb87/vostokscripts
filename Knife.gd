extends Node3D
class_name Knife


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("Data")
@export var knifeData: Resource

@export_group("References")
@export var animator: AnimationTree
@export var arms: MeshInstance3D
@export var knife: MeshInstance3D
@export var handle: Node3D
@export var collision: RayCast3D
@export var raycast: RayCast3D

var weaponManager
var canCombo = false
var isThrowing = false
var slashTime = 0.4
var stabTime = 0.6
var attack = 1

var comboTimer = 0.0
var comboTime = 0.5

var interface
var stickRay = preload("res://Resources/StickRay.tscn")
var knifeRevival = preload("res://Resources/Revival.tscn")

func _ready():
    weaponManager = get_parent()
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")
    animator.active = true

func _input(event):
    if gameData.isInspecting:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                if gameData.inspectPosition == 1:
                    animator["parameters/conditions/Inspect_Front"] = false
                    animator["parameters/conditions/Inspect_Back"] = true
                    gameData.inspectPosition = 2

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                if gameData.inspectPosition == 2:
                    animator["parameters/conditions/Inspect_Front"] = true
                    animator["parameters/conditions/Inspect_Back"] = false
                    gameData.inspectPosition = 1

func _physics_process(delta):
    if gameData.freeze || gameData.isInspecting || gameData.interface || gameData.settings || gameData.toggleDelay:
        return

    comboTimer += delta

    if comboTimer > comboTime:
        canCombo = true
    else:
        canCombo = false


    if Input.is_action_just_pressed(("slash")) && !isThrowing:

        if animator["parameters/conditions/Slash_03"] && canCombo:
            animator["parameters/conditions/Slash_04"] = true
            comboTimer = 0.0
            attack = 4


        elif animator["parameters/conditions/Slash_02"] && canCombo:
            animator["parameters/conditions/Slash_03"] = true
            comboTimer = 0.0
            attack = 3


        elif animator["parameters/conditions/Slash_01"] && canCombo:
            animator["parameters/conditions/Slash_02"] = true
            comboTimer = 0.0
            attack = 2


        elif !animator["parameters/conditions/Slash_01"]:
            animator["parameters/conditions/Slash_01"] = true
            comboTimer = 0.0
            attack = 1


    if Input.is_action_just_pressed(("stab")) && !isThrowing:

        if animator["parameters/conditions/Stab_03"] && canCombo:
            animator["parameters/conditions/Stab_04"] = true
            comboTimer = 0.0
            attack = 8


        elif animator["parameters/conditions/Stab_02"] && canCombo:
            animator["parameters/conditions/Stab_03"] = true
            comboTimer = 0.0
            attack = 7


        elif animator["parameters/conditions/Stab_01"] && canCombo:
            animator["parameters/conditions/Stab_02"] = true
            comboTimer = 0.0
            attack = 6


        elif !animator["parameters/conditions/Stab_01"]:
            animator["parameters/conditions/Stab_01"] = true
            comboTimer = 0.0
            attack = 5


    if Input.is_action_just_pressed(("prepare_throw")) && !gameData.interaction:
        if !isThrowing:
            animator["parameters/conditions/Throw_Start"] = true
            animator["parameters/conditions/Throw_Reset"] = false
            animator["parameters/conditions/Throw_End"] = false
            isThrowing = true
        else:
            animator["parameters/conditions/Throw_Start"] = false
            animator["parameters/conditions/Throw_Reset"] = true
            animator["parameters/conditions/Throw_End"] = false
            isThrowing = false

    if Input.is_action_just_pressed(("throw")) && isThrowing:
        animator["parameters/conditions/Throw_End"] = true
        isThrowing = false

func HitCheck():
    if raycast.is_colliding():
        var hitCollider = raycast.get_collider()
        var hitPoint = raycast.get_collision_point()
        var hitNormal = raycast.get_collision_normal()
        var hitSurface = raycast.get_collider().get("surfaceType")
        KnifeDecal(hitCollider, hitPoint, hitNormal, hitSurface)

        if hitCollider is Hitbox:
            hitCollider.ApplyDamage(knifeData.damage)

func KnifeDecal(hitCollider, hitPoint, hitNormal, hitSurface):
    var knifeDecal: Node3D

    if hitCollider is Hitbox:
        knifeDecal = weaponManager.hitKnife.instantiate()
    else:
        knifeDecal = weaponManager.hitKnife.instantiate()

    hitCollider.add_child(knifeDecal)
    knifeDecal.global_transform.origin = hitPoint

    if hitNormal == Vector3(0, 1, 0):
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == Vector3(0, -1, 0):
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else:
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.DOWN)

    if attack == 1:
        knifeDecal.global_rotation_degrees.z = 30.0
    elif attack == 2:
        knifeDecal.global_rotation_degrees.z = 10.0
    elif attack == 3:
        knifeDecal.global_rotation_degrees.z = -10.0
    elif attack == 4:
        knifeDecal.global_rotation_degrees.z = -30.0
    elif attack == 5:
        knifeDecal.global_rotation_degrees.z = 15.0
    elif attack == 6:
        knifeDecal.global_rotation_degrees.z = 0.0
    elif attack == 7:
        knifeDecal.global_rotation_degrees.z = -30.0
    elif attack == 8:
        knifeDecal.global_rotation_degrees.z = 45.0

    if hitCollider is Hitbox:
        knifeDecal.PlayKnifeHitFlesh(attack)
    else:
        knifeDecal.PlayKnifeHit(hitSurface)

func InspectKnife():
    animator.active = true
    animator["parameters/conditions/Inspect_Front"] = true
    animator["parameters/conditions/Inspect_Idle"] = false

func ResetInspect():
    if gameData.inspectPosition == 1:
        animator["parameters/conditions/Inspect_Front"] = false
        animator["parameters/conditions/Inspect_Idle"] = true
    elif gameData.inspectPosition == 2:
        animator["parameters/conditions/Inspect_Back"] = false
        animator["parameters/conditions/Inspect_Idle"] = true
        gameData.inspectPosition = 1

func AttackFinished():
    attack = 0
    isThrowing = false
    animator["parameters/conditions/Slash_01"] = false
    animator["parameters/conditions/Slash_02"] = false
    animator["parameters/conditions/Slash_03"] = false
    animator["parameters/conditions/Slash_04"] = false
    animator["parameters/conditions/Stab_01"] = false
    animator["parameters/conditions/Stab_02"] = false
    animator["parameters/conditions/Stab_03"] = false
    animator["parameters/conditions/Stab_04"] = false
    animator["parameters/conditions/Throw_Start"] = false
    animator["parameters/conditions/Throw_Reset"] = false
    animator["parameters/conditions/Throw_End"] = false

func ThrowFinished():
    weaponManager.ClearWeapons()
    animator.active = false

func ThrowExecute():

    knife.hide()


    gameData.knife = false


    interface.RemoveKnife()


    if interface.preloader.get(knifeData.file):


        var throwDirection
        var throwPosition
        var throwRotation

        throwDirection = global_transform.basis.z
        throwPosition = handle.global_position
        throwRotation = Vector3(0, global_rotation_degrees.y, 0)


        var map = get_tree().current_scene.get_node("/root/Map")
        var file = interface.preloader.get(knifeData.file)

        if file:
            var pickup = interface.preloader.get(knifeData.file).instantiate()
            map.add_child(pickup)


            var ray = stickRay.instantiate()
            pickup.get_child(0).add_child(ray)


            ray.pickup = pickup
            ray.target_position = Vector3(0, 0, knifeData.stickDistance)


            var revival = knifeRevival.instantiate()
            pickup.get_child(0).add_child(revival)


            revival.pickup = pickup
            revival.interface = interface

            pickup.get_child(0).position = throwPosition
            pickup.get_child(0).rotation_degrees = throwRotation
            pickup.KnifeThrow(throwDirection, 30.0, 30.0)
        else:
            print("File not found: " + knifeData.name)

func SlashAudio():
    var slash = audioInstance2D.instantiate()
    add_child(slash)
    slash.PlayInstance(audioLibrary.knifeSlash)

func StabAudio():
    var stab = audioInstance2D.instantiate()
    add_child(stab)
    stab.PlayInstance(audioLibrary.knifeStab)

func ThrowStartAudio():
    var throwStart = audioInstance2D.instantiate()
    add_child(throwStart)
    throwStart.PlayInstance(audioLibrary.knifeThrowStart)

func ThrowEndAudio():
    var throwEnd = audioInstance2D.instantiate()
    add_child(throwEnd)
    throwEnd.PlayInstance(audioLibrary.knifeThrowEnd)

func InspectStartAudio():
    var inspectStart = audioInstance2D.instantiate()
    add_child(inspectStart)
    inspectStart.PlayInstance(audioLibrary.knifeInspectStart)

func InspectEndAudio():
    var inspectEnd = audioInstance2D.instantiate()
    add_child(inspectEnd)
    inspectEnd.PlayInstance(audioLibrary.knifeInspectEnd)

func InspectTurnAudio():
    var inspectTurn = audioInstance2D.instantiate()
    add_child(inspectTurn)
    inspectTurn.PlayInstance(audioLibrary.knifeInspectTurn)
