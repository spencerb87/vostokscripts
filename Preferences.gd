extends Resource
class_name Preferences


@export var masterVolume = 1.0
@export var ambientVolume = 1.0
@export var musicVolume = 0.0
@export var musicPreset = 1


@export var lookSensitivity = 1.0
@export var aimSensitivity = 1.0
@export var scopeSensitivity = 1.0


@export var interpolate = true
@export var baseFOV = 70.0
@export var headbob = 1.0


@export var exposure = 1.0
@export var contrast = 1.0
@export var saturation = 1.0


@export var sharpness = 0.25


@export var map = true
@export var time = true
@export var FPS = true
@export var stats = true


@export var tooltip = 1
@export var tooltipDelay = 1


@export var season = 1
@export var TOD = 2
@export var weather = 1
@export var aurora = false


@export var frameLimit = 5


@export var rendering = 3
@export var lighting = 3


@export var antialiasing = 3
@export var natureAA = 1


@export var mouseMode = 1
@export var sprintMode = 1
@export var leanMode = 1
@export var aimMode = 1


@export var displayMode = 1
@export var windowSize = 0
@export var monitor = 0


@export var action_events: Dictionary = {}

func Save() -> void :
    ResourceSaver.save(self, "user://Preferences.tres")

static func Load() -> Preferences:
    var resource: Preferences = load("user://Preferences.tres") as Preferences

    if !resource:
        resource = Preferences.new()

    return resource
