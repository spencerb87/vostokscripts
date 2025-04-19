extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

@export var slotData: SlotData
@export var collision: CollisionShape3D

@export_group("Details")
@export var attachments: Node3D
@export var effects: Node3D
@onready var rigidbody: RigidBody3D = $RigidBody3D

var interface

func _ready():
    rigidbody.inertia = Vector3(0.05, 0.05, 0.05)
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")
    Freeze()

func Interact():
    if interface.Pickup(slotData):
        PickupAudio()

func UpdateTooltip():
    if slotData.itemData:

        if slotData.itemData.type == "Ammunition":
            gameData.tooltip = "Pick " + "[" + slotData.itemData.name + " (" + "x" + str(slotData.ammo) + ")" + "]"

        elif slotData.itemData.type == "Armor":
            gameData.tooltip = "Pick " + "[" + slotData.itemData.name + "]"

        elif slotData.itemData.type == "Equipment" && slotData.itemData.carrier && slotData.armor:
            gameData.tooltip = "Pick " + "[" + slotData.itemData.name + " (" + slotData.armor.rating + ")" + "]"

        elif slotData.itemData.type == "Equipment" && slotData.itemData.helmet:
            gameData.tooltip = "Pick " + "[" + slotData.itemData.name + " (" + slotData.itemData.rating + ")" + "]"
        else:
            gameData.tooltip = "Pick " + "[" + slotData.itemData.name + "]"

func SetDropVelocity(direction: Vector3, force: float):
    rigidbody.linear_velocity = direction * force

func SetKnifeVelocity(direction: Vector3, force: float, angular: float):
    collision.shape.size.y = 0.3
    rigidbody.linear_velocity = direction * force
    rigidbody.angular_velocity = rigidbody.basis.x * angular

func UpdateAttachments():

    if slotData.muzzle != null:

        if attachments.get_child_count() != 0:
            for attachment in attachments.get_children():
                if attachment.name == slotData.muzzle.file:
                    attachment.visible = true


    if slotData.optic != null:

        if attachments.get_child_count() != 0:
            for attachment in attachments.get_children():
                if attachment.name == slotData.optic.file:
                    attachment.position.z += slotData.position
                    attachment.visible = true


        if slotData.itemData.useMount && !slotData.optic.hasMount:
            for attachment in attachments.get_children():
                if attachment.name == "Mount":
                    attachment.visible = true

func PickupAudio():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.pickup)
    queue_free()

func KnifeThrow(direction: Vector3, force: float, angular: float):

    collision.shape.size.z = 0.1


    rigidbody.body_entered.connect(self.Collided)


    rigidbody.linear_velocity = direction * force
    rigidbody.angular_velocity = rigidbody.basis.x * angular


    rigidbody.gravity_scale = 1
    rigidbody.sleeping = false
    rigidbody.can_sleep = false
    rigidbody.freeze = false
    rigidbody.continuous_cd = true
    rigidbody.max_contacts_reported = 1
    rigidbody.contact_monitor = true
    rigidbody.freeze_mode = rigidbody.FREEZE_MODE_STATIC

func Collided(body: Node3D):

    for child in rigidbody.get_children():
        if child is RayCast3D:
            rigidbody.remove_child(child)
            child.queue_free()


    rigidbody.body_entered.disconnect(self.Collided)
    Unfreeze()


    collision.shape.size.z = slotData.itemData.collisionSize.z


    var hitSurface = body.get("surfaceType")


    BounceAudio(hitSurface)

func Stick(hitCollider):

    for child in rigidbody.get_children():
        if child is RayCast3D:
            rigidbody.remove_child(child)
            child.queue_free()


    rigidbody.body_entered.disconnect(self.Collided)


    if hitCollider is Hitbox:
        Freeze()
        reparent(hitCollider, true)
        hitCollider.ApplyDamage(slotData.itemData.damage)


        var stick = audioInstance3D.instantiate()
        rigidbody.add_child(stick)
        stick.PlayInstance(audioLibrary.knifeStickFlesh, 10, 50)


    else:

        var hitSurface = hitCollider.get("surfaceType")


        if hitSurface == 3 || hitSurface == 4 || hitSurface == 6 || hitSurface == 7:
            Unfreeze()
            BounceAudio(hitSurface)


            collision.shape.size.z = slotData.itemData.collisionSize.z


        else:
            Freeze()
            reparent(hitCollider, true)
            StickAudio(hitSurface)


            collision.shape.size.z = slotData.itemData.collisionSize.z

func Freeze():
    rigidbody.gravity_scale = 1
    rigidbody.sleeping = true
    rigidbody.can_sleep = true
    rigidbody.freeze = true
    rigidbody.continuous_cd = false
    rigidbody.max_contacts_reported = 0
    rigidbody.freeze_mode = rigidbody.FREEZE_MODE_STATIC

func Kinematic():
    rigidbody.gravity_scale = 0
    rigidbody.sleeping = true
    rigidbody.can_sleep = true
    rigidbody.freeze = false
    rigidbody.continuous_cd = true
    rigidbody.max_contacts_reported = 1
    rigidbody.contact_monitor = true
    rigidbody.freeze_mode = rigidbody.FREEZE_MODE_KINEMATIC

func Unfreeze():
    rigidbody.gravity_scale = 1
    rigidbody.sleeping = false
    rigidbody.can_sleep = false
    rigidbody.freeze = false
    rigidbody.continuous_cd = false
    rigidbody.max_contacts_reported = 0
    rigidbody.freeze_mode = rigidbody.FREEZE_MODE_STATIC
    await get_tree().create_timer(1.0).timeout;
    rigidbody.can_sleep = true

func BounceAudio(surface):
    var bounce = audioInstance3D.instantiate()
    rigidbody.add_child(bounce)


    if surface == 1 || surface == 2:
        bounce.PlayInstance(audioLibrary.knifeBounceSoil, 10, 50)


    elif surface == 3 || surface == 4 || surface == 6 || surface == 7:
        bounce.PlayInstance(audioLibrary.knifeBounceMetal, 10, 50)


    elif surface == 5:
        bounce.PlayInstance(audioLibrary.knifeBounceWood, 10, 50)


    else:
        bounce.PlayInstance(audioLibrary.knifeBounceWood, 10, 50)

func StickAudio(surface):
    var stick = audioInstance3D.instantiate()
    rigidbody.add_child(stick)


    if surface == 1 || surface == 2:
        stick.PlayInstance(audioLibrary.knifeStickSoil, 10, 50)


    elif surface == 5:
        stick.PlayInstance(audioLibrary.knifeStickWood, 10, 50)


    else:
        stick.PlayInstance(audioLibrary.knifeStickWood, 10, 50)
