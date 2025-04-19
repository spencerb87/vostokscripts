extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")


@export var decal: Decal
@export var impact: GPUParticles3D

func _ready():
    var tween = create_tween()
    tween.tween_callback(Fade).set_delay(10.0)

func Fade():
    var tween = create_tween()
    tween.tween_property($Decal, "scale", Vector3(0.1, 0.1, 0.1), 2.0)
    tween.tween_callback(queue_free).set_delay(2.0)

func PlayHit(hitSurface):
    var hitAudio = audioInstance3D.instantiate()
    add_child(hitAudio)

    if gameData.season == 1:
        if hitSurface == 1:
            hitAudio.PlayInstance(audioLibrary.hitGrass, 10, 50)
            impact.emitting = true
        elif hitSurface == 2:
            hitAudio.PlayInstance(audioLibrary.hitDirt, 10, 50)
            impact.emitting = true
        elif hitSurface == 3:
            hitAudio.PlayInstance(audioLibrary.hitAsphalt, 10, 50)
            impact.emitting = true
        elif hitSurface == 4:
            hitAudio.PlayInstance(audioLibrary.hitRock, 10, 50)
            impact.emitting = true
        elif hitSurface == 5:
            hitAudio.PlayInstance(audioLibrary.hitWood, 10, 50)
            impact.emitting = true
        elif hitSurface == 6:
            hitAudio.PlayInstance(audioLibrary.hitMetal, 10, 50)
            impact.emitting = true
        elif hitSurface == 7:
            hitAudio.PlayInstance(audioLibrary.hitConcrete, 10, 50)
            impact.emitting = true
        elif hitSurface == 8:
            hitAudio.PlayInstance(audioLibrary.hitTarget, 200, 400)
            impact.emitting = true
        elif hitSurface == 9:
            hitAudio.PlayInstance(audioLibrary.hitWater, 10, 50)
            decal.albedo_mix = 0
        else:
            hitAudio.PlayInstance(audioLibrary.hitGrass, 10, 50)
            impact.emitting = true

    elif gameData.season == 2:
        if hitSurface == 1:
            hitAudio.PlayInstance(audioLibrary.hitSnowSoft, 10, 50)
            impact.emitting = true
        elif hitSurface == 2:
            hitAudio.PlayInstance(audioLibrary.hitSnowHard, 10, 50)
            impact.emitting = true
        elif hitSurface == 3:
            hitAudio.PlayInstance(audioLibrary.hitAsphalt, 10, 50)
            impact.emitting = true
        elif hitSurface == 4:
            hitAudio.PlayInstance(audioLibrary.hitRock, 10, 50)
            impact.emitting = true
        elif hitSurface == 5:
            hitAudio.PlayInstance(audioLibrary.hitWood, 10, 50)
            impact.emitting = true
        elif hitSurface == 6:
            hitAudio.PlayInstance(audioLibrary.hitMetal, 10, 50)
            impact.emitting = true
        elif hitSurface == 7:
            hitAudio.PlayInstance(audioLibrary.hitConcrete, 10, 50)
            impact.emitting = true
        elif hitSurface == 8:
            hitAudio.PlayInstance(audioLibrary.hitTarget, 200, 400)
            impact.emitting = true
        elif hitSurface == 9:
            hitAudio.PlayInstance(audioLibrary.hitWater, 10, 50)
            decal.albedo_mix = 0
        else:
            hitAudio.PlayInstance(audioLibrary.hitGrass, 10, 400)
            impact.emitting = true

func PlayKnifeHit(hitSurface):
    var hitAudio = audioInstance3D.instantiate()
    add_child(hitAudio)

    if hitSurface == 1:
        hitAudio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)
    elif hitSurface == 2:
        hitAudio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)
    elif hitSurface == 3:
        hitAudio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif hitSurface == 4:
        hitAudio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif hitSurface == 5:
        hitAudio.PlayInstance(audioLibrary.knifeHitWood, 10, 50)
    elif hitSurface == 6:
        hitAudio.PlayInstance(audioLibrary.knifeHitMetal, 10, 50)
    elif hitSurface == 7:
        hitAudio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif hitSurface == 8:
        hitAudio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif hitSurface == 9:
        hitAudio.PlayInstance(audioLibrary.hitWater, 10, 50)
    else:
        hitAudio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)

func PlayKnifeHitFlesh(attack: int):
    var hitAudio = audioInstance3D.instantiate()
    add_child(hitAudio)


    if attack < 4:
        hitAudio.PlayInstance(audioLibrary.knifeHitFleshSlash, 10, 50)

    else:
        hitAudio.PlayInstance(audioLibrary.knifeHitFleshStab, 10, 50)

func Emit():
    impact.emitting = true

func Cache():
    impact.emitting = true;
