extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var nextMap: String
@export var currentMap: String
@export var shelterEnter: bool
@export var shelterExit: bool
@export var tutorialExit: bool
@export var deactivated: bool

func _ready():
    if deactivated:
        var material = get_child(0).get_surface_override_material(0)
        material.albedo_color = Color.RED

func Interact():
    if deactivated:
        return

    gameData.isTransitioning = true

    if tutorialExit:
        Loader.LoadScene("Menu")
    else:
        gameData.currentMap = nextMap
        gameData.previousMap = currentMap
        Loader.LoadScene(nextMap)
        Loader.SaveCharacter()

        if shelterExit:
            Loader.SaveShelter()

func UpdateTooltip():
    if shelterEnter:
        gameData.tooltip = "Enter " + "[" + nextMap + "]"
    elif shelterExit:
        gameData.tooltip = "Exit " + "[" + currentMap + "]"
    elif tutorialExit:
        gameData.tooltip = "End tutorial [Main Menu]"
    elif deactivated:
        gameData.tooltip = "Transition not available"
    else:
        gameData.tooltip = "Transition " + "[" + nextMap + "]"
