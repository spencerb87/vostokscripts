extends Node3D


var gameData = preload("res://Resources/GameData.tres")

var weaponData: Resource
var currentKick = Vector3.ZERO
var currentRotation = Vector3.ZERO

func _ready():
    weaponData = owner.weaponData

func _physics_process(delta):
    if gameData.freeze || gameData.flycam:
        return

    CalculateRecoil(delta)

func CalculateRecoil(delta):
    if owner.isUpgraded:
        currentRotation = lerp(currentRotation, Vector3.ZERO, delta * weaponData.upgrade.rotationRecovery)
        rotation = lerp(rotation, currentRotation, delta * weaponData.upgrade.rotationPower)

        currentKick = lerp(currentKick, Vector3.ZERO, delta * weaponData.upgrade.kickRecovery)
        position = lerp(position, currentKick, delta * weaponData.upgrade.kickPower)
    else:
        currentRotation = lerp(currentRotation, Vector3.ZERO, delta * weaponData.rotationRecovery)
        rotation = lerp(rotation, currentRotation, delta * weaponData.rotationPower)

        currentKick = lerp(currentKick, Vector3.ZERO, delta * weaponData.kickRecovery)
        position = lerp(position, currentKick, delta * weaponData.kickPower)

func ApplyRecoil():
    if owner.isUpgraded:
        if gameData.firemode == 1:
            currentRotation = Vector3( - weaponData.upgrade.verticalRecoil, randf_range( - weaponData.upgrade.horizontalRecoil, weaponData.upgrade.horizontalRecoil), 0.0)
        else:
            currentRotation = Vector3( - weaponData.upgrade.verticalRecoil / 2, randf_range( - weaponData.upgrade.horizontalRecoil, weaponData.upgrade.horizontalRecoil), 0.0)
        currentKick = Vector3(0.0, 0.0, - weaponData.upgrade.kick)
    else:
        if gameData.firemode == 1:
            currentRotation = Vector3( - weaponData.verticalRecoil, randf_range( - weaponData.horizontalRecoil, weaponData.horizontalRecoil), 0.0)
        else:
            currentRotation = Vector3( - weaponData.verticalRecoil / 2, randf_range( - weaponData.horizontalRecoil, weaponData.horizontalRecoil), 0.0)
        currentKick = Vector3(0.0, 0.0, - weaponData.kick)
