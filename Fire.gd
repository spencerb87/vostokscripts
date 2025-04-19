extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var requirement: ItemData

@export var effect: Node3D
@export var audio: AudioStreamPlayer3D
@export var forceActive: bool
@export var random: bool
@export var fireAudio: bool
@onready var area = $Area

@export_group("Materials")
@export var emissive = false
@export var mesh: MeshInstance3D
@export var baseMaterial: Material
@export var litMaterial: Material

var isActive = false

func _ready():
    if forceActive:
        isActive = true
        Activate()
    elif random:
        var roll = randi_range(0, 2)

        if roll > 1:
            isActive = true
            Activate()
        else:
            isActive = false
            Deactivate()
    else:
        isActive = false
        Deactivate()

func Interact():
    isActive = !isActive

    if isActive:
        Activate()
        IgniteAudio()
    else:
        Deactivate()
        ExtinguishAudio()

func Activate():
    effect.show()
    area.monitorable = true

    if fireAudio:
        audio.play()

    if emissive && mesh && baseMaterial && litMaterial:
        mesh.set_surface_override_material(0, litMaterial)

func Deactivate():
    effect.hide()
    area.monitorable = false

    if fireAudio:
        audio.stop()

    if emissive && mesh && baseMaterial && litMaterial:
        mesh.set_surface_override_material(0, baseMaterial)

func UpdateTooltip():
    if isActive:
        gameData.tooltip = "Fire [Extinguish]"
    else:
        gameData.tooltip = "Fire [Ignite]"

func IgniteAudio():
    var ignite = audioInstance2D.instantiate()
    add_child(ignite)
    ignite.PlayInstance(audioLibrary.ignite)

func ExtinguishAudio():
    var extinguish = audioInstance2D.instantiate()
    add_child(extinguish)
    extinguish.PlayInstance(audioLibrary.extinguish)
