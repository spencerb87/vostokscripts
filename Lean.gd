extends Node3D


var gameData = preload("res://Resources/GameData.tres")


var leanSpeed = 5.0
var leanAngle = 15.0
var leanOffset = 0.2

var leanLToggle = false
var leanRToggle = false

func _physics_process(delta):
    if gameData.freeze || gameData.isFlying:
        return

    if gameData.leanMode == 1:
        if Input.is_action_pressed(("lean_L")) && !gameData.leanLBlocked:
            rotation_degrees.z = lerp(rotation_degrees.z, leanAngle, delta * leanSpeed)
            position.x = lerp(position.x, - leanOffset, delta * leanSpeed)
        elif Input.is_action_pressed(("lean_R")) && !gameData.leanRBlocked:
            rotation_degrees.z = lerp(rotation_degrees.z, - leanAngle, delta * leanSpeed)
            position.x = lerp(position.x, leanOffset, delta * leanSpeed)
        else:
            rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta * leanSpeed)
            position.x = lerp(position.x, 0.0, delta * leanSpeed)

    elif gameData.leanMode == 2:
        if Input.is_action_just_pressed(("lean_L")) && !gameData.leanLBlocked:
            leanRToggle = false
            leanLToggle = !leanLToggle

        elif Input.is_action_just_pressed(("lean_R")) && !gameData.leanRBlocked:
            leanLToggle = false
            leanRToggle = !leanRToggle

        if leanLToggle:
            rotation_degrees.z = lerp(rotation_degrees.z, leanAngle, delta * leanSpeed)
            position.x = lerp(position.x, - leanOffset, delta * leanSpeed)
        elif leanRToggle:
            rotation_degrees.z = lerp(rotation_degrees.z, - leanAngle, delta * leanSpeed)
            position.x = lerp(position.x, leanOffset, delta * leanSpeed)
        else:
            rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta * leanSpeed)
            position.x = lerp(position.x, 0.0, delta * leanSpeed)
