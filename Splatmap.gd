extends Node


var gameData = preload("res://Resources/GameData.tres")

@export var splatmap: Texture2D
var targetColor: Color
var targetPosition: Vector2


var scanTimer = 0.0
var scanCycle = 1.0

func _physics_process(delta):
    scanTimer += delta

    if scanTimer > scanCycle:
        targetPosition = Vector2(gameData.playerPosition.x, gameData.playerPosition.z)
        targetColor = splatmap.get_image().get_pixel(targetPosition.x, targetPosition.y)
        print(targetPosition)
        print(targetColor)
        scanTimer = 0.0
