extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var location = $Info / Location
@onready var time = $Info / Time
@onready var FPS = $Info / FPS
@onready var stats = $Stats
@onready var frames = $Info / FPS / Frames
@onready var tooltip = $Tooltip
@onready var label = $Tooltip / Label
@onready var water = $Water
@onready var permadeath = $Permadeath


@onready var overweight = $Stats / Medical / Overweight
@onready var starvation = $Stats / Medical / Starvation
@onready var dehydration = $Stats / Medical / Dehydration
@onready var bleeding = $Stats / Medical / Bleeding
@onready var fracture = $Stats / Medical / Fracture
@onready var hypothermia = $Stats / Medical / Hypothermia
@onready var burn = $Stats / Medical / Burn
@onready var poisoning = $Stats / Medical / Poisoning
@onready var radiation = $Stats / Medical / Radiation
@onready var rupture = $Stats / Medical / Rupture

func _ready():
    if gameData.flycam:
        hide()
    else:
        tooltip.hide()
        water.hide()

        var map = get_tree().current_scene.get_node("/root/Map")

        if map:
            label.text = str(gameData.tooltip)
            location.text = str(map.mapName + " (" + map.mapType + ")")

            if map.mapType == "Vostok":
                permadeath.show()
            else:
                permadeath.hide()

func _physics_process(_delta):
    if gameData.flycam:
        return

    if FPS.visible:
        frames.text = str(Engine.get_frames_per_second())

    if gameData.interaction:
        tooltip.show()
        label.text = str(gameData.tooltip)
    else:
        tooltip.hide()

    if gameData.isWater:
        water.show()
    else:
        water.hide()

func ToggleLocation(state: bool):
    if state:
        location.show()
    else:
        location.hide()

func ToggleTime(state: bool):
    if state:
        time.show()
    else:
        time.hide()

func ToggleFPS(state: bool):
    if state:
        FPS.show()
    else:
        FPS.hide()

func ToggleStats(state: bool):
    if state:
        stats.show()
    else:
        stats.hide()

func UpdateTime():
    if gameData.TOD == 1:
        time.text = "Time: Dawn"
    elif gameData.TOD == 2:
        time.text = "Time: Day"
    elif gameData.TOD == 3:
        time.text = "Time: Dusk"
    elif gameData.TOD == 4:
        time.text = "Time: Night"
