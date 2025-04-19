extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var nvg = $UI_NVG
@onready var hud = $UI_HUD
@onready var settings = $UI_Settings
@onready var interface = $UI_Interface
@onready var inspect = $UI_Inspect


@onready var weapons = $"../Camera/Weapons"

func _ready():
    settings.hide()
    interface.hide()
    inspect.hide()

func _input(event):
    if gameData.isDead || gameData.isTransitioning || gameData.isReloading || gameData.isPreparing || gameData.isInserting || gameData.isPlacing || gameData.flycam || (interface.container && gameData.isOccupied):
        return


    if event.is_action_pressed("settings") && (gameData.interface || gameData.settings || gameData.isInspecting):

        if (gameData.interface && !interface.container && !interface.trader) || gameData.settings:
            ClickAudio()

        Return()
        return


    if event.is_action_pressed("settings") && !gameData.interface && !gameData.isInspecting:
        ClickAudio()
        ToggleSettings()


    if event.is_action_pressed("interface") && !gameData.settings && !gameData.isInspecting:

        if (gameData.interface && !interface.container && !interface.trader):
            ClickAudio()
        elif !gameData.interface:
            ClickAudio()

        ToggleInterface()


    if event.is_action_pressed("interact") && (interface.container || interface.trader):
        ToggleInterface()


    if event.is_action_pressed("inspect") && !gameData.settings && !gameData.interface:
        ToggleInspect()

func Return():
    if gameData.settings:
        settings.hide()
        gameData.settings = false
        UIClose()

    if gameData.interface:
        interface.hide()
        interface.CloseInterface()
        gameData.interface = false
        UIClose()

    if gameData.isInspecting:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        weapons.get_child(0).ResetInspect()
        inspect.HideWeaponUI()
        inspect.hide()
        gameData.isInspecting = false
        UIClose()

func ToggleInspect():
    if weapons.get_child_count() == 0:
        return

    if weapons.get_child(0) is Knife:
        gameData.isInspecting = !gameData.isInspecting

        if gameData.isInspecting:
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            weapons.get_child(0).InspectKnife()
            await get_tree().create_timer(0.1).timeout;
            inspect.show()
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            weapons.get_child(0).ResetInspect()
            inspect.hide()

    if weapons.get_child(0) is Weapon:
        gameData.isInspecting = !gameData.isInspecting

        if gameData.isInspecting:
            Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
            weapons.get_child(0).InspectWeapon()
            inspect.ShowWeaponUI()
            await get_tree().create_timer(0.1).timeout;
            inspect.show()
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            weapons.get_child(0).ResetInspect()
            inspect.HideWeaponUI()
            inspect.hide()

func ToggleSettings():
    gameData.settings = !gameData.settings

    if gameData.settings:
        settings.show()
        UIOpen()
    else:
        settings.hide()
        UIClose()

func ToggleInterface():
    gameData.interface = !gameData.interface

    if gameData.isInspecting:
        inspect.hide()

    if gameData.interface:
        interface.show()
        interface.OpenInterface()
        UIOpen()
    else:
        interface.hide()
        interface.CloseInterface()
        UIClose()

func OpenContainer(container: LootContainer):
    gameData.interface = true
    interface.container = container
    interface.show()
    interface.OpenInterface()
    UIOpen()

func OpenTrader(trader):
    gameData.interface = true
    interface.trader = trader
    interface.show()
    interface.OpenInterface()
    UIOpen()

func UIOpen():
    gameData.freeze = true
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    hud.hide()

func UIClose():
    gameData.freeze = false
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    hud.show()

    gameData.toggleDelay = true
    await get_tree().create_timer(0.1).timeout;
    gameData.toggleDelay = false

func ClickAudio():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
