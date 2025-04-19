extends Node


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var cache = preload("res://Resources/Cache.tscn")


@onready var camera = $"../../Camera"
@onready var controller = $"../../Controller"
@onready var preloader = $"../Preloader"
@onready var settings = $"../../UI/UI_Settings"

var scanPhase = 0
var shaderCache

func _ready():
    CreateCache()
    gameData.isCaching = true
    camera.global_position = Vector3(0, 2, 0)

func _physics_process(delta):
    if gameData.isCaching:
        FrustrumScan(delta)

func FrustrumScan(delta):
    camera.rotation_degrees.y += delta * 250.0

    if camera.rotation_degrees.y >= 360 && scanPhase == 0:
        camera.global_position = Vector3(0, 2, 100)
        scanPhase = 1

    if camera.rotation_degrees.y >= 360 && scanPhase == 1:
        camera.global_position = Vector3(0, 2, 0)
        scanPhase = 2

    if camera.rotation_degrees.y >= 360 && scanPhase == 2:
        camera.global_position = Vector3(0, 2, -100)
        scanPhase = 3

    if camera.rotation_degrees.y >= 360 && scanPhase == 3:
        CacheReady()

func CreateCache():
    shaderCache = cache.instantiate()
    camera.add_child(shaderCache)
    shaderCache.transform.origin.z -= 2.0

func CacheReady():
    gameData.isCaching = false
    Loader.FadeOutLoading()


    if gameData.flycam:
        ClearCache()
        SpawnFlycam()

    else:
        settings.UpdateWorld()
        ClearCache()
        Spawn()

func ClearCache():
    camera.remove_child(shaderCache)
    shaderCache.HideDecals()
    shaderCache.queue_free()

func Spawn():
    var target: String
    var map = get_tree().current_scene.get_node("/root/Map")
    var transitions = get_tree().get_nodes_in_group("Transition")

    controller.global_position = Vector3(0, 1, 0)


    if map.mapName == "Tutorial":
        target = "Transition_Menu"


    elif map.mapName == "Attic":
        Loader.LoadCharacter()
        Loader.LoadShelter()
        target = "Door_Attic_Exit"


    elif map.mapName == "Village":
        Loader.LoadCharacter()

        if gameData.previousMap == "Attic":
            target = "Door_Attic_Enter"
        elif gameData.previousMap == "Shipyard":
            target = "Transition_Shipyard"
        elif gameData.previousMap == "Highway":
            target = "Transition_Highway"


    elif map.mapName == "Shipyard":
        Loader.LoadCharacter()

        if gameData.previousMap == "Village":
            target = "Transition_Village"


    elif map.mapName == "Highway":
        Loader.LoadCharacter()

        if gameData.previousMap == "Village":
            target = "Transition_Village"
        elif gameData.previousMap == "Minefield":
            target = "Transition_Minefield"


    elif map.mapName == "Minefield":
        Loader.LoadCharacter()

        if gameData.previousMap == "Highway":
            target = "Transition_Highway"
        elif gameData.previousMap == "Radar":
            target = "Transition_Radar"


    elif map.mapName == "Radar":
        Loader.LoadCharacter()
        PlayVostokEnter()

        if gameData.previousMap == "Minefield":
            target = "Transition_Minefield"


    for transition in transitions:
        if transition.name == target:
            controller.global_transform = transition.global_transform
            controller.rotation_degrees.y = controller.rotation_degrees.y - 180
            controller.position -= controller.transform.basis.z * 1.0

    gameData.isTransitioning = false
    gameData.isOccupied = false
    gameData.freeze = false

func SpawnFlycam():
    var map = get_tree().current_scene.get_node("/root/Map")
    var transitions = get_tree().get_nodes_in_group("Transition")


    if map.mapName == "Village":
        controller.global_position = Vector3(5, 10, 0)

    elif map.mapName == "Shipyard":
        controller.global_position = Vector3(-30, 10, 80)

    elif map.mapName == "Highway":
        controller.global_position = Vector3(0, 20, 95)

    elif map.mapName == "Minefield":
        controller.global_position = Vector3(5, 10, 80)

    elif map.mapName == "Radar":
        controller.global_position = Vector3(5, 10, 95)


    for transition in transitions:
        transition.deactivated = true

        if !transition.shelterEnter:
            transition.hide()


    gameData.isTransitioning = false
    gameData.isOccupied = false
    gameData.freeze = false

func PlayVostokEnter():
    var vostokEnter = audioInstance2D.instantiate()
    add_child(vostokEnter)
    vostokEnter.PlayInstance(audioLibrary.vostokEnter)
