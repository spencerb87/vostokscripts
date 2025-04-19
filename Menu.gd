extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var main = $Main
@onready var kits = $Kits
@onready var settings = $Settings
@onready var tools = $Tools
@onready var patches = $Patches
@onready var flycam = $Flycam


@onready var audio = $Audio


@onready var newButton = $Main / Buttons / New
@onready var loadButton = $Main / Buttons / Load
@onready var tutorialButton = $Main / Buttons / Tutorial
@onready var patchesButton = $Main / Buttons / Patches
@onready var settingsButton = $Main / Buttons / Settings
@onready var toolsButton = $Main / Buttons / Tools
@onready var quitButton = $Main / Buttons / Quit
@onready var musicOffButton = $Music / Buttons / Music_Off
@onready var musicOnButton = $Music / Buttons / Music_On

func _ready():
	Engine.max_fps = 120

	gameData.Reset()
	gameData.menu = true

	main.show()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()

	Loader.FadeOut()
	Loader.ShowCursor()


	if Loader.CheckVersion() && Loader.CheckShelter():
		loadButton.disabled = false
	else:
		loadButton.disabled = true

func _on_new_pressed():
	main.hide()
	kits.show()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_kits_continue_pressed():
	gameData.flycam = false
	Loader.CreateVersion()
	Loader.LoadScene("Attic")
	Loader.ResetSave()
	Deactivate()
	PlayClick()

func _on_kits_return_pressed():
	main.show()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_load_pressed():
	gameData.flycam = false
	Loader.LoadScene("Attic")
	Deactivate()
	PlayClick()

func _on_tutorial_pressed():
	gameData.flycam = false
	Loader.LoadScene("Tutorial")
	Deactivate()
	PlayClick()

func _on_settings_pressed() -> void :
	main.hide()
	kits.hide()
	patches.hide()
	settings.show()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_settings_return_pressed() -> void :
	main.show()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_patches_pressed():
	main.hide()
	kits.hide()
	patches.show()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_patches_return_pressed():
	main.show()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_tools_pressed():
	main.hide()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.show()
	flycam.hide()
	PlayClick()

func _on_tools_return_pressed():
	main.show()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.hide()
	PlayClick()

func _on_flycam_pressed():
	main.hide()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.hide()
	flycam.show()
	PlayClick()

func _on_village_pressed():
	gameData.flycam = true
	Loader.LoadScene("Village")
	Deactivate()
	PlayClick()

func _on_shipyard_pressed():
	gameData.flycam = true
	Loader.LoadScene("Shipyard")
	Deactivate()
	PlayClick()

func _on_highway_pressed() -> void :
	gameData.flycam = true
	Loader.LoadScene("Highway")
	Deactivate()
	PlayClick()

func _on_minefield_pressed() -> void :
	gameData.flycam = true
	Loader.LoadScene("Minefield")
	Deactivate()
	PlayClick()

func _on_radar_pressed() -> void :
	gameData.flycam = true
	Loader.LoadScene("Radar")
	Deactivate()
	PlayClick()

func _on_flycam_return_pressed():
	main.hide()
	kits.hide()
	patches.hide()
	settings.hide()
	tools.show()
	flycam.hide()
	PlayClick()

func _on_quit_pressed():
	Loader.Quit()
	Deactivate()
	PlayClick()

func _on_music_on_pressed():
	audio.stream_paused = false
	PlayClick()

func _on_music_off_pressed():
	audio.stream_paused = true
	PlayClick()

func Deactivate():
	newButton.mouse_filter = MOUSE_FILTER_IGNORE
	loadButton.mouse_filter = MOUSE_FILTER_IGNORE
	tutorialButton.mouse_filter = MOUSE_FILTER_IGNORE
	patchesButton.mouse_filter = MOUSE_FILTER_IGNORE
	settingsButton.mouse_filter = MOUSE_FILTER_IGNORE
	toolsButton.mouse_filter = MOUSE_FILTER_IGNORE
	quitButton.mouse_filter = MOUSE_FILTER_IGNORE
	musicOffButton.mouse_filter = MOUSE_FILTER_IGNORE
	musicOnButton.mouse_filter = MOUSE_FILTER_IGNORE

func PlayClick():
	var clickAudio = audioInstance2D.instantiate()
	add_child(clickAudio)
	clickAudio.PlayInstance(audioLibrary.UIClick)
