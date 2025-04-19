extends CSGBox3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var submerged = $Submerged
@onready var masterBus = AudioServer.get_bus_index("Master")
@onready var ambientBus = AudioServer.get_bus_index("Ambient")
var masterLowPass
var lowPassEffect
var lowPassValue


var world
var controller
var weapons

func _ready():
    world = get_parent_node_3d()
    controller = get_tree().current_scene.get_node("/root/Map/Core/Controller")
    weapons = get_tree().current_scene.get_node("/root/Map/Core/Camera/Weapons")
    masterLowPass = AudioServer.get_bus_effect(0, 0)
    lowPassEffect = AudioServer.get_bus_effect(1, 0)
    masterLowPass.cutoff_hz = 20000

func _physics_process(_delta):
    if gameData.season == 1 && !gameData.indoor && visible:
        if controller.global_position.y < -2.0:
            gameData.isWater = true
        elif controller.global_position.y > -2.0:
            gameData.isWater = false

        if controller.camera.global_position.y < -1.98 && !gameData.isSubmerged:
            gameData.isSubmerged = true
            gameData.isFalling = false
            masterLowPass.cutoff_hz = 2000
            world.environment.environment.fog_enabled = true
            world.environment.environment.volumetric_fog_enabled = false

            PlayWaterDive()
            submerged.play()

            if gameData.primary || gameData.secondary || gameData.knife:
                weapons.ClearWeapons()
                weapons.PlayUnequip()

        elif controller.camera.global_position.y > -1.98 && gameData.isSubmerged:
            gameData.isSubmerged = false
            masterLowPass.cutoff_hz = 20000
            world.environment.environment.fog_enabled = false
            world.environment.environment.volumetric_fog_enabled = true

            if gameData.oxygen < 50:
                PlayWaterGasp()

            PlayWaterSurface()
            submerged.stop()
    else:
        gameData.isWater = false
        gameData.isSubmerged = false

func PlayWaterDive():
    var waterDive = audioInstance2D.instantiate()
    add_child(waterDive)
    waterDive.PlayInstance(audioLibrary.waterDive)

func PlayWaterSurface():
    var waterSurface = audioInstance2D.instantiate()
    add_child(waterSurface)
    waterSurface.PlayInstance(audioLibrary.waterSurface)

func PlayWaterGasp():
    var waterGasp = audioInstance2D.instantiate()
    add_child(waterGasp)
    waterGasp.PlayInstance(audioLibrary.waterGasp)
