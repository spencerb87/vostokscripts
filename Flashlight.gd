extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var lightWorld = $World
@onready var lightFPS = $FPS

func _ready():
    gameData.flashlight = false
    lightWorld.light_energy = 0.0
    lightFPS.light_energy = 0.0

func _physics_process(_delta):
    if gameData.freeze || gameData.flycam:
        return

    if Input.is_action_just_pressed(("flashlight")):
        gameData.flashlight = !gameData.flashlight
        FlashlightAudio()

        if gameData.flashlight:
            lightWorld.spot_range = 50.0
            lightWorld.light_energy = 5.0
            lightFPS.omni_range = 2.0
            lightFPS.light_energy = 1.0
        else:
            lightWorld.spot_range = 0.0
            lightWorld.light_energy = 0.0
            lightFPS.omni_range = 0.0
            lightFPS.light_energy = 0.0

func FlashlightAudio():
    var flashlight = audioInstance2D.instantiate()
    add_child(flashlight)
    flashlight.PlayInstance(audioLibrary.flashlight)

func Load():
    if gameData.flashlight:
        lightWorld.spot_range = 50.0
        lightWorld.light_energy = 5.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 1.0
    else:
        lightWorld.spot_range = 0.0
        lightWorld.light_energy = 0.0
        lightFPS.omni_range = 0.0
        lightFPS.light_energy = 0.0
