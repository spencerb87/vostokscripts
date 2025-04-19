extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

var dynamicTimer = 0.0
var map


const crow = preload("res://Audio/Events/Dynamic/Crow.tres")
const woodBreak = preload("res://Audio/Events/Dynamic/Wood_Break.tres")
const treeCreak = preload("res://Audio/Events/Dynamic/Tree_Creak.tres")
const owl = preload("res://Audio/Events/Dynamic/Owl.tres")
const windGust = preload("res://Audio/Events/Dynamic/Wind_Gust.tres")


const cuckoo = preload("res://Audio/Events/Dynamic/Cuckoo.tres")
const birdAlarm = preload("res://Audio/Events/Dynamic/Bird_Alarm.tres")
const blackbird = preload("res://Audio/Events/Dynamic/Blackbird.tres")
const chaffinch = preload("res://Audio/Events/Dynamic/Chaffinch.tres")
const crane = preload("res://Audio/Events/Dynamic/Crane.tres")
const fox = preload("res://Audio/Events/Dynamic/Fox.tres")
const goshawk = preload("res://Audio/Events/Dynamic/Goshawk.tres")
const magpie = preload("res://Audio/Events/Dynamic/Magpie.tres")
const jackdaw = preload("res://Audio/Events/Dynamic/Jackdaw.tres")
const plover = preload("res://Audio/Events/Dynamic/Plover.tres")
const rooster = preload("res://Audio/Events/Dynamic/Rooster.tres")
const seagull = preload("res://Audio/Events/Dynamic/Seagull.tres")
const woodpecker = preload("res://Audio/Events/Dynamic/Woodpecker.tres")
const woodpidgeon = preload("res://Audio/Events/Dynamic/Woodpidgeon.tres")
const wren = preload("res://Audio/Events/Dynamic/Wren.tres")


const bear = preload("res://Audio/Events/Dynamic/Bear.tres")
const dog = preload("res://Audio/Events/Dynamic/Dog.tres")
const wolf = preload("res://Audio/Events/Dynamic/Wolf.tres")
const car = preload("res://Audio/Events/Dynamic/Car.tres")
const fighterJet = preload("res://Audio/Events/Dynamic/Fighter_Jet.tres")
const helicopter = preload("res://Audio/Events/Dynamic/Helicopter.tres")
const tank = preload("res://Audio/Events/Dynamic/Tank.tres")
const artillery = preload("res://Audio/Events/Dynamic/Artillery.tres")
const explosion = preload("res://Audio/Events/Dynamic/Explosion.tres")
const rumble = preload("res://Audio/Events/Dynamic/Rumble.tres")
const hit = preload("res://Audio/Events/Dynamic/Hit.tres")


var area05Day: Array[AudioEvent]
var area05DayEvents = [crow, woodBreak, cuckoo, birdAlarm, blackbird, chaffinch, crane, fox, goshawk, jackdaw, magpie, plover, rooster, seagull, wren]
var area05Night: Array[AudioEvent]
var area05NightEvents = [crow, woodBreak, crane, fox, owl, treeCreak, windGust, woodpecker, woodpidgeon]


var borderZoneDay: Array[AudioEvent]
var borderZoneDayEvents = [bear, crow, birdAlarm, crane, dog, woodBreak, windGust, car, fighterJet, helicopter, tank, rumble]
var borderZoneNight: Array[AudioEvent]
var borderZoneNightEvents = [bear, crow, crane, dog, woodBreak, owl, treeCreak, windGust, wolf, car, fighterJet, helicopter, tank, rumble]


var vostokDay: Array[AudioEvent]
var vostokDayEvents = [fighterJet, helicopter, tank, artillery, explosion, rumble, hit]
var vostokNight: Array[AudioEvent]
var vostokNightEvents = [treeCreak, windGust, wolf, fighterJet, helicopter, tank, artillery, explosion, rumble, hit]

func _ready() -> void :
    map = get_tree().current_scene.get_node("/root/Map")
    dynamicTimer = randf_range(1, 10)
    AssignEvents()

func AssignEvents():
    for event in area05DayEvents:
        area05Day.append(event)
    for event in area05NightEvents:
        area05Night.append(event)

    for event in borderZoneDayEvents:
        borderZoneDay.append(event)
    for event in borderZoneNightEvents:
        borderZoneNight.append(event)

    for event in vostokDayEvents:
        vostokDay.append(event)
    for event in vostokNightEvents:
        vostokNight.append(event)

func _physics_process(delta):
    dynamicTimer -= delta

    if dynamicTimer <= 0:
        if !gameData.indoor:
            PlayDynamicAudio()

        dynamicTimer = randf_range(1, 60)

func PlayDynamicAudio():
    var audio = audioInstance3D.instantiate()
    add_child(audio)

    var xDirection = randi_range(0, 1)
    var zDirection = randi_range(0, 1)
    var xPosition
    var zPosition


    if xDirection == 0:
        xPosition = randf_range(-200, -100)

    else:
        xPosition = randf_range(100, 200)


    if zDirection == 0:
        zPosition = randf_range(-200, -100)

    else:
        zPosition = randf_range(100, 200)

    var audioPositionX = gameData.playerPosition.x + xPosition
    var audioPositionY = gameData.playerPosition.y
    var audioPositionZ = gameData.playerPosition.z + zPosition

    audio.global_position = Vector3(audioPositionX, audioPositionY, audioPositionZ)

    if map.mapType == "Area 05":
        if gameData.TOD == 4:
            var randomIndex = randi_range(0, area05Night.size() - 1)
            var randomEvent: AudioEvent = area05Night[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)
        else:
            var randomIndex = randi_range(0, area05Day.size() - 1)
            var randomEvent: AudioEvent = area05Day[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)

    elif map.mapType == "Border Zone":
        if gameData.TOD == 4:
            var randomIndex = randi_range(0, borderZoneNight.size() - 1)
            var randomEvent: AudioEvent = borderZoneNight[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)
        else:
            var randomIndex = randi_range(0, borderZoneDay.size() - 1)
            var randomEvent: AudioEvent = borderZoneDay[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)

    elif map.mapType == "Vostok":
        if gameData.TOD == 4:
            var randomIndex = randi_range(0, vostokNight.size() - 1)
            var randomEvent: AudioEvent = vostokNight[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)
        else:
            var randomIndex = randi_range(0, vostokDay.size() - 1)
            var randomEvent: AudioEvent = vostokDay[randomIndex]
            audio.PlayInstance(randomEvent, 100, 400)
