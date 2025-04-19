extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

var placable: Node3D
var rigidbody: RigidBody3D
var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var lerpSpeed = 7.5
var maxDistance = 2.5
var minDistance = 0.5
var distance = 1.0
var angle = 0.0
var rotateMode = false
var initialWait = false
var waitTime = 0.1

@onready var interactor = $"../Interactor"

func _input(event):
    if gameData.freeze || gameData.isReloading || gameData.isInspecting || !gameData.isPlacing:
        return

    if rotateMode:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                angle += 0.1

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                angle -= 0.1
    else:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP && - position.z < maxDistance:
                distance += 0.05

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && - position.z > minDistance:
                distance -= 0.05


    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && gameData.isPlacing:
        rotateMode = !rotateMode

func _physics_process(delta):
    if gameData.freeze || gameData.isReloading || gameData.isInspecting:
        return

    if Input.is_action_just_pressed(("place")):

        if gameData.interaction && interactor.target && interactor.target.owner.is_in_group("Item") && !gameData.isPlacing && !initialWait:
            distance = 1.0
            angle = 0.0

            placable = interactor.target.owner
            rigidbody = placable.get_child(0)
            rigidbody.body_entered.connect(self.Collided)
            gameData.isPlacing = true

            rigidbody.rotation.x = deg_to_rad(0)
            rigidbody.rotation.z = deg_to_rad(0)
            rigidbody.linear_velocity = Vector3.ZERO
            rigidbody.angular_velocity = Vector3.ZERO


            placable.Freeze()
            initialWait = true
            await get_tree().create_timer(waitTime).timeout;
            initialWait = false
            placable.Kinematic()


        elif gameData.isPlacing && placable && !initialWait:
            rigidbody.body_entered.disconnect(self.Collided)
            rigidbody.linear_velocity = Vector3(0, 0.1, 0)
            rigidbody.angular_velocity = Vector3(1, 1, 1)
            placable.Unfreeze()
            placable = null
            gameData.isPlacing = false

    if gameData.isPlacing && placable:
        position = - transform.basis.z * distance + placable.slotData.itemData.defaultOffset
        var defaultRotation = deg_to_rad(placable.slotData.itemData.defaultRotation)


        placable.get_child(0).global_position = lerp(placable.get_child(0).global_position, global_position, delta * 5.0)
        placable.get_child(0).global_rotation.y = lerp_angle(placable.get_child(0).global_rotation.y, global_rotation.y + defaultRotation + angle, delta * 5.0)

func Collided(body: Node3D):
    if body.is_in_group("Weapon_Wall") && (placable.slotData.itemData.type == "Weapon" || placable.slotData.itemData.type == "Attachment" || placable.slotData.itemData.type == "Knife"):

        var defaultRotation = deg_to_rad(placable.slotData.itemData.defaultRotation)
        rigidbody.global_rotation.y = body.global_rotation.y + defaultRotation


        if body.global_transform.basis.z.z == 1 || body.global_transform.basis.z.z == -1:
            rigidbody.global_position.z = body.global_position.z
            rigidbody.global_position += body.global_transform.basis.z * placable.slotData.itemData.wallOffset

        elif body.global_transform.basis.z.x == 1 || body.global_transform.basis.z.x == -1:
            rigidbody.global_position.x = body.global_position.x
            rigidbody.global_position += body.global_transform.basis.z * placable.slotData.itemData.wallOffset

        rigidbody.body_entered.disconnect(self.Collided)
        placable.Freeze()
        placable = null
        gameData.isPlacing = false
        AttachAudio()
    else:
        rigidbody.body_entered.disconnect(self.Collided)
        placable.Unfreeze()
        placable = null
        gameData.isPlacing = false

func ActionPlace(target: Node3D):
    placable = target
    rigidbody = placable.get_child(0)
    rigidbody.body_entered.connect(self.Collided)
    gameData.isPlacing = true

    rigidbody.rotation.x = deg_to_rad(0)
    rigidbody.rotation.z = deg_to_rad(0)
    rigidbody.linear_velocity = Vector3.ZERO
    rigidbody.angular_velocity = Vector3.ZERO

    distance = 1.0
    angle = 0.0

    position = - transform.basis.z * distance + placable.slotData.itemData.defaultOffset
    var defaultRotation = deg_to_rad(placable.slotData.itemData.defaultRotation)
    placable.get_child(0).global_position = global_position
    placable.get_child(0).global_rotation.y = global_rotation.y + defaultRotation + angle


    placable.Freeze()
    initialWait = true
    await get_tree().create_timer(waitTime).timeout;
    initialWait = false
    placable.Kinematic()

func AttachAudio():
    var attach = audioInstance2D.instantiate()
    add_child(attach)
    attach.PlayInstance(audioLibrary.UIAttach)
