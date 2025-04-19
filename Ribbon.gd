@tool
extends Node3D

@export var hang = 0.0
@export var tilt = 0.0

@onready var poles = $Poles
@onready var mesh = $Mesh
@onready var path = $Path

@export var generate: bool = false:
    set = ExecuteGenerateRibbon

@export var clear: bool = false:
    set = ExecuteClearRibbon

func ExecuteGenerateRibbon(_value: bool) -> void :

    path.curve.clear_points()
    clear = false

    var index = 0
    var currentPole = 0
    var lastPole = poles.get_child_count()
    var tilting = false

    for pole in poles.get_children():
        path.curve.add_point(pole.get_child(0).global_position)
        path.curve.set_point_out(index, Vector3(0, hang, 0))
        path.curve.set_point_tilt(index, 10)

        tilting = !tilting

        if tilting:
            path.curve.set_point_tilt(index, tilt)
        else:
            path.curve.set_point_tilt(index, 0)

        index += 1
        currentPole += 1

        if currentPole == lastPole:
            path.curve.add_point(poles.get_child(0).get_child(0).global_position)

    generate = false

func ExecuteClearRibbon(_value: bool) -> void :
    path.curve.clear_points()
    clear = false
