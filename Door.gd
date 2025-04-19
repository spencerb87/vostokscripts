extends Node3D
class_name Door


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

@export_group("General")
@export var openAngle: Vector3
@export var openOffset: Vector3
@export var audioEvent: AudioEvent
@export var pivot: Node3D
@export var handle: Node3D

var defaultPosition = Vector3.ZERO
var defaultRotation = Vector3.ZERO
var targetRotation = Vector3.ZERO
var openSpeed = 4.5
var isOpen = false


var isOccupied = false
var occupiedTime = 5.0
var occupiedTimer = 0.0


var animationTime = 0.0

func _ready():
    animationTime = 0.0
    defaultPosition = pivot.position
    defaultRotation = pivot.rotation_degrees

func _physics_process(delta):
    if animationTime > 0:
        animationTime -= delta

        if isOpen:
            pivot.position = lerp(pivot.position, openOffset + defaultPosition, delta * openSpeed)
            pivot.rotation_degrees = lerp(pivot.rotation_degrees, openAngle + defaultRotation, delta * openSpeed)
        else:
            pivot.position = lerp(pivot.position, defaultPosition, delta * openSpeed)
            pivot.rotation_degrees = lerp(pivot.rotation_degrees, defaultRotation, delta * openSpeed)

    if isOccupied:
        occupiedTimer += delta

        if occupiedTimer > occupiedTime:
            occupiedTimer = 0.0
            isOccupied = false

func Interact():
    animationTime += 4.0

    if isOccupied:
        return

    isOpen = !isOpen
    DoorAudio()

func UpdateTooltip():
    if isOccupied:
        gameData.tooltip = "Door [Occupied]"
    else:
        if isOpen && !isOccupied:
            gameData.tooltip = "Door [Close]"
        else:
            gameData.tooltip = "Door [Open]"

func DoorAudio():
    var audio = audioInstance3D.instantiate()
    handle.add_child(audio)
    audio.PlayInstance(audioEvent, 5, 50)
