extends RayCast3D


var gameData = preload("res://Resources/GameData.tres")


var scanTimer = 0.0
var scanCycle = 0.1
var target

func _physics_process(delta):
    if gameData.freeze || gameData.flycam || gameData.isReloading || gameData.isPreparing || gameData.isInserting || gameData.isInspecting || gameData.isPlacing || gameData.isOccupied || gameData.isCrafting:
        gameData.interaction = false
        return

    Interact()
    scanTimer += delta

    if is_colliding():
        if scanTimer > scanCycle:
            target = get_collider()

            if target.is_in_group("Interactable"):
                gameData.interaction = true
                target.owner.UpdateTooltip()
            else:
                gameData.interaction = false

            scanTimer = 0.0
    else:
        gameData.interaction = false

func Interact():
    if Input.is_action_just_pressed(("interact")) && gameData.interaction && !gameData.isOccupied:
        target.owner.Interact()
