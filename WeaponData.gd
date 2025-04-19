extends ItemData
class_name WeaponData

@export_group("Action")
enum WeaponAction{Rifle, Pistol, Bolt, Shotgun}
@export var action = WeaponAction.Rifle


@export_group("Audio")
@export var fireSemi: Resource
@export var fireAuto: Resource
@export var fireSuppressed: Resource
@export var tailOutdoor: Resource
@export var tailIndoor: Resource
@export var tailOutdoorSuppressed: Resource
@export var tailIndoorSuppressed: Resource
@export var magazineOut: Resource
@export var magazineIn: Resource
@export var slideRelease: Resource
@export var slideLocked: Resource
@export var boltOpen: Resource
@export var boltClosed: Resource
@export var insert: Resource
@export var additional: Resource


@export_group("Caliber")
@export var ammo: ItemData
@export var caliber: String
enum Cartridge{Pistol, Rifle, Shell}
@export var cartridge = Cartridge.Pistol


@export_group("Fire")
@export var damage = 0.0
@export var penetration = 0
@export var fireRate = 0.0
@export var magazineSize = 0


@export_group("Recoil")
@export var kick = 0.0
@export var kickPower = 0.0
@export var kickRecovery = 0.0
@export var verticalRecoil = 0.0
@export var horizontalRecoil = 0.0
@export var rotationPower = 0.0
@export var rotationRecovery = 0.0


@export_group("Rig")
enum SlideDirection{X, Y, Z}
@export var slideDirection = SlideDirection.X
@export var slideMovement = 0.0
@export var slideSpeed = 0.0
@export var slideLock = false
enum SelectorDirection{X, Y, Z}
@export var selectorDirection = SelectorDirection.X
@export var selectorSpeed = 0.0
@export var semiRotation = 0.0
@export var autoRotation = 0.0
@export var foldSightsRotation = 0.0


@export_group("Modding")
@export var muzzleSlot = false
@export var opticSlot = false
@export var statsSlot = false
@export var ammoSlot = false
@export var useMount = false
@export var nativeSuppressor = false
@export var foldSights = false
@export var attachments: Array[AttachmentData]


@export_group("Handling")
@export var lowPosition = Vector3.ZERO
@export var lowRotation = Vector3.ZERO
@export var highPosition = Vector3.ZERO
@export var highRotation = Vector3.ZERO
@export var aimPosition = Vector3.ZERO
@export var aimRotation = Vector3.ZERO
@export var cantedPosition = Vector3.ZERO
@export var cantedRotation = Vector3.ZERO
@export var inspectPosition = Vector3.ZERO
@export var inspectRotation = Vector3.ZERO
@export var collisionPosition = Vector3.ZERO
@export var collisionRotation = Vector3.ZERO
