extends Node3D

var gameData = preload("res://Resources/GameData.tres")

enum Type{Muzzle, Magazine, Optic, Stats, Ammo}
@export var type = Type.Muzzle

var camera: Camera
var inspect
var target

func _ready():
    camera = get_tree().current_scene.get_node("/root/Map/Core/Camera")
    inspect = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Inspect")

    if type == Type.Muzzle:
        target = inspect.muzzle
    elif type == Type.Magazine:
        target = inspect.magazine
    elif type == Type.Optic:
        target = inspect.optic
    elif type == Type.Stats:
        target = inspect.stats
    elif type == Type.Ammo:
        target = inspect.ammo

func _physics_process(_delta):
    if gameData.isInspecting && target != null:
        target.global_position = camera.unproject_position(global_position)
