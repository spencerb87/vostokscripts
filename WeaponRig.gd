extends Skeleton3D


var gameData = preload("res://Resources/GameData.tres")


@export var weaponData: Resource
@export var dynamicSlide: bool
@export var dynamicSelector: bool
@export var slideIndex = 0
@export var selectorIndex = 0
@export var singleRotation = 0.0
@export var autoRotation = 0.0

var slideValue = 0.0
var selectorValue = 0.0
var selectorSpeed = 25.0

var initialSlidePosition = Vector3.ZERO
var targetSlidePosition = Vector3.ZERO

var initialSelectorRotation = Vector3.ZERO
var targetSelectorRotation = Vector3.ZERO

func _ready():
    initialSlidePosition = get_bone_pose_position(slideIndex)
    initialSelectorRotation = get_bone_pose_rotation(selectorIndex).get_euler()

func _physics_process(delta):

    if dynamicSlide:
        Slide(delta)

    if dynamicSelector:
        Selector(delta)

func Slide(delta):
    if gameData.isFiring || gameData.ammo == 0:
        slideValue = lerp(slideValue, weaponData.slideMovement, delta * weaponData.slideSpeed)
    else:
        slideValue = lerp(slideValue, 0.0, delta * weaponData.slideSpeed)


    if weaponData.slideDirection == 0:
        targetSlidePosition = Vector3(initialSlidePosition.x - slideValue, initialSlidePosition.y, initialSlidePosition.z)
    elif weaponData.slideDirection == 1:
        targetSlidePosition = Vector3(initialSlidePosition.x, initialSlidePosition.y - slideValue, initialSlidePosition.z)
    else:
        targetSlidePosition = Vector3(initialSlidePosition.x, initialSlidePosition.y, initialSlidePosition.z - slideValue)

    set_bone_pose_position(slideIndex, targetSlidePosition)

func Selector(delta):
    if gameData.firemode == 1:
        selectorValue = move_toward(selectorValue, singleRotation, delta * selectorSpeed)
    else:
        selectorValue = move_toward(selectorValue, autoRotation, delta * selectorSpeed)

    targetSelectorRotation = Vector3(initialSelectorRotation.x, initialSelectorRotation.y, initialSelectorRotation.z + selectorValue)
    set_bone_pose_rotation(selectorIndex, Quaternion.from_euler(targetSelectorRotation))
