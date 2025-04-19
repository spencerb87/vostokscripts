extends Node3D
class_name Mine


var gameData = preload("res://Resources/GameData.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
const explosionVFX = preload("res://Resources/Explosion.tscn")

@export var mine: Node3D
@export var explosion: AudioEvent
@export var spring: AudioEvent
var isDetonated = false
var detonationHeight = 2.0
var character

func _ready():
    character = get_tree().current_scene.get_node("/root/Map/Core/Controller/Character/")

func _physics_process(delta):
    if gameData.flycam:
        return

    if isDetonated:
        mine.position.y = move_toward(mine.position.y, detonationHeight, delta * 10.0)

        if mine.position.y == detonationHeight:
            ExplosionAudio()
            character.ExplosionDamage()
            var vfx = explosionVFX.instantiate()
            vfx.position = global_position + Vector3(0, detonationHeight, 0)
            get_tree().get_root().add_child(vfx)
            vfx.Emit()
            vfx.Flash()
            queue_free()

func Detonate():
    if gameData.flycam:
        return

    if !isDetonated:
        SpringAudio()
        isDetonated = true

func InstantDetonate():
    if !isDetonated:


        if global_transform.origin.distance_to(gameData.playerPosition) < 6.0:
            character.ExplosionDamage()

        ExplosionAudio()
        var vfx = explosionVFX.instantiate()
        vfx.position = global_position + Vector3(0, 0.5, 0)
        get_tree().get_root().add_child(vfx)
        vfx.Emit()
        vfx.Flash()
        queue_free()

func SpringAudio():
    var springAudio = audioInstance3D.instantiate()
    springAudio.position = global_position
    get_tree().get_root().add_child(springAudio)
    springAudio.PlayInstance(spring, 10, 20)

func ExplosionAudio():
    var explosionAudio = audioInstance3D.instantiate()
    explosionAudio.position = global_position
    get_tree().get_root().add_child(explosionAudio)
    explosionAudio.PlayInstance(explosion, 20, 200)
