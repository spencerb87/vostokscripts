extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var audioClips: Array[AudioStreamWAV]
@export var forceActive: bool
@export var randomActive: bool
@export var randomPlay = false
@export var audioPlayer: AudioStreamPlayer3D
var clipOrder = 0

var isActive = false

func _ready():
    if forceActive:
        isActive = true
    elif randomActive:
        var roll = randi_range(0, 2)

        if roll == 1:
            isActive = true
        else:
            isActive = false

func _physics_process(_delta):
    if !audioPlayer.is_playing() && isActive:
        if randomPlay:
            audioPlayer.stream = GetRandomClip()
            audioPlayer.play()
        else:
            audioPlayer.stream = GetNextClip()
            audioPlayer.play()

func Interact():
    isActive = !isActive

    if isActive:
        var randomIndex: int = randi_range(0, audioLibrary.radio.audioClips.size() - 1)
        audioPlayer.stream = audioLibrary.radio.audioClips[randomIndex]
        audioPlayer.play()
    else:
        RadioTuningAudio()
        audioPlayer.stop()

func GetRandomClip():
    var randomIndex: int = randi_range(0, audioClips.size() - 1)
    return audioClips[randomIndex]

func GetNextClip():
    if clipOrder >= audioClips.size() - 1:
        clipOrder = 0
    else:
        clipOrder += 1

func UpdateTooltip():
    if isActive:
        gameData.tooltip = "Radio [Turn Off]"
    else:
        gameData.tooltip = "Radio [Turn On]"

func RadioTuningAudio():
    var radioTuning = audioInstance2D.instantiate()
    add_child(radioTuning)
    radioTuning.PlayInstance(audioLibrary.radio)
