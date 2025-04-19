extends Area3D


var gameData = preload("res://Resources/GameData.tres")

var sensorTimer = 0.0
var sensorCycle = 0.2

@onready var character = $"../Character"

func _physics_process(delta):
    if gameData.isCaching:
        return

    sensorTimer += delta

    if sensorTimer > sensorCycle:
        Detect()
        sensorTimer = 0.0

func Detect():
    var overlaps = get_overlapping_areas()

    if overlaps.size() > 0:
        for overlap in overlaps:
            if overlap is Area:

                if overlap.type == "Indoor":
                    gameData.indoor = true
                else:
                    gameData.indoor = false

                if overlap.type == "Mine":
                    if !overlap.owner.isDetonated:
                        overlap.owner.Detonate()

                if overlap.type == "Fire":
                    gameData.isBurning = true
                    if !gameData.burn:
                        character.Burn(true)
                else:
                    gameData.isBurning = false

                if overlap.type == "Heat":
                    gameData.heat = true
                else:
                    gameData.heat = false

    else:
        gameData.indoor = false
        gameData.isBurning = false
        gameData.heat = false
