extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var settings = $"../UI_Settings"
@onready var active = $Active
var world

func _ready():
    world = get_tree().current_scene.get_node("/root/Map/World")
    gameData.NVG = false
    active.visible = false

func _physics_process(_delta):
    if gameData.freeze || gameData.flycam:
        return

    if gameData.isSubmerged:
        gameData.NVG = false
        active.visible = false
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 1.0
        return

    if Input.is_action_just_pressed(("nvg")):
        gameData.NVG = !gameData.NVG
        NVGAudio()

        if gameData.NVG:
            world.environment.environment.tonemap_exposure = 1.0
            world.environment.environment.tonemap_white = 0.1
            active.visible = true
        else:
            world.environment.environment.tonemap_exposure = 1.0
            world.environment.environment.tonemap_white = 1.0
            active.visible = false

func NVGAudio():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.flashlight)

func Load():
    if gameData.NVG:
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 0.1
        active.visible = true
    else:
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 1.0
        active.visible = false
