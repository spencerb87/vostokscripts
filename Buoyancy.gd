extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export var simulate = false

@export_group("Noise Profile")
@export var noise: FastNoiseLite

@export_group("Noise Paramenters")
@export var bobFrequency = 1.0
@export var bobAmplitude = 10.0
@export var rotationFrequency = 0.1
@export var rotationAmplitude = 2.0

var bobVector = Vector2.ZERO
var bobIndex = 0.0

var noiseOffset = Vector3.ZERO
var noiseValue = Vector3.ZERO

var finalFrequency = 0.0
var finalAmplitude = 0.0

var initialPosition = Vector3.ZERO
var initialRotation = Vector3.ZERO

func _ready():
    initialPosition = global_position
    initialRotation = rotation_degrees

    bobIndex = randf_range(0, 100.0)
    noiseOffset.x = randf_range(0, 100.0)
    noiseOffset.y = randf_range(0, 100.0)
    noiseOffset.z = randf_range(0, 100.0)

func _physics_process(delta):
    if !simulate:
        return


    if gameData.season == 2:
        return


    bobIndex += bobFrequency * delta
    bobVector.y = sin(bobIndex)

    if gameData.weather == 4:
        position.y = lerp(initialPosition.y, bobVector.y * 2.0 * bobAmplitude, delta)
    else:
        position.y = lerp(initialPosition.y, bobVector.y * bobAmplitude, delta)


    if gameData.weather == 4:
        finalFrequency = lerp(finalFrequency, rotationFrequency * 2.0, delta)
        finalAmplitude = lerp(finalAmplitude, rotationAmplitude * 2.0, delta)
    else:
        finalFrequency = lerp(finalFrequency, rotationFrequency, delta)
        finalAmplitude = lerp(finalAmplitude, rotationAmplitude, delta)

    var noiseScroll = delta * finalFrequency

    noiseOffset.x += noiseScroll
    noiseOffset.y += noiseScroll
    noiseOffset.z += noiseScroll

    noiseValue.x = noise.get_noise_2d(noiseOffset.x, 0.0)
    noiseValue.y = noise.get_noise_2d(noiseOffset.y, 1.0)
    noiseValue.z = noise.get_noise_2d(noiseOffset.z, 2.0)

    noiseValue *= finalAmplitude

    rotation_degrees.x = initialRotation.x + noiseValue.x
    rotation_degrees.y = initialRotation.y + noiseValue.y
    rotation_degrees.z = initialRotation.z + noiseValue.z
