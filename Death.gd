extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var loadButton = $Main / Buttons / Load
@onready var menuButton = $Main / Buttons / Menu
@onready var quitButton = $Main / Buttons / Quit

func _ready():
    Engine.max_fps = 120

    gameData.Reset()
    Loader.FadeOut()
    Loader.ShowCursor()


    if Loader.CheckVersion() && Loader.CheckShelter():
        loadButton.disabled = false
    else:
        loadButton.disabled = true

func _on_load_pressed():
    Loader.LoadScene("Attic")
    Deactivate()
    PlayClick()

func _on_menu_pressed():
    Loader.LoadScene("Menu")
    Deactivate()
    PlayClick()

func _on_quit_pressed():
    Loader.Quit()
    Deactivate()
    PlayClick()

func Deactivate():
    loadButton.mouse_filter = MOUSE_FILTER_IGNORE
    menuButton.mouse_filter = MOUSE_FILTER_IGNORE
    quitButton.mouse_filter = MOUSE_FILTER_IGNORE

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
