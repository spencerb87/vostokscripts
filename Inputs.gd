extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")
var preferences: Preferences


@onready var actions = % Actions


@onready var normal = $Modes / Settings / Mouse_Options / Normal
@onready var inverted = $Modes / Settings / Mouse_Options / Inverted
@onready var sprintHold = $Modes / Settings / Sprint_Options / Sprint_Hold
@onready var sprintToggle = $Modes / Settings / Sprint_Options / Sprint_Toggle
@onready var leanHold = $Modes / Settings / Lean_Options / Lean_Hold
@onready var leanToggle = $Modes / Settings / Lean_Options / Lean_Toggle
@onready var aimHold = $Modes / Settings / Aim_Options / Aim_Hold
@onready var aimToggle = $Modes / Settings / Aim_Options / Aim_Toggle


var isRemapping = false
var actionToRemap = null
var buttonToRemap = null
var remapButton = preload("res://Resources/RemapButton.tscn")


var inputs = {
    "forward": "Forward", 
    "backward": "Backward", 
    "left": "Left", 
    "right": "Right", 
    "crouch": "Crouch", 
    "jump": "Jump", 
    "sprint": "Sprint", 
    "lean_L": "Lean Left", 
    "lean_R": "Lean Right", 
    "swim": "Swim Mode", 
    "primary": "Draw Primary", 
    "secondary": "Draw Secondary", 
    "knife": "Draw Knife", 
    "low": "Lower Weapon", 
    "high": "Raise Weapon", 
    "aim": "Aim", 
    "canted": "Canted Aim", 
    "fire": "Fire", 
    "reload": "Reload", 
    "firemode": "Firemode", 
    "inspect": "Inspect Weapon", 
    "slash": "Slash", 
    "stab": "Stab", 
    "prepare_throw": "Prepare Throw", 
    "throw": "Throw", 
    "prepare": "Prepare Insert", 
    "insert": "Insert Cartridge", 
    "interact": "Interact", 
    "place": "Placement", 
    "flashlight": "Flashlight", 
    "nvg": "NVG", 
    "interface": "Interface", 
    "hover_tooltip": "Hover Tooltip", 
    "item_drop": "Drop Item", 
    "item_transfer": "Transfer Item", 
    "item_equip": "Equip Item", 
    "rail_movement": "Rail Movement", 
    "secondary_optic": "Secondary Optic"
}

func _ready():
    if FileAccess.file_exists("user://Preferences.tres"):
        preferences = Preferences.Load()
    else:
        preferences = Preferences.new()
        ResourceSaver.save(preferences, "user://Preferences.tres")

    CreateActions()

    if preferences.mouseMode == 1:
        gameData.mouseMode = 1
        normal.button_pressed = true
        inverted.button_pressed = false
    elif preferences.mouseMode == 2:
        gameData.mouseMode = 2
        normal.button_pressed = false
        inverted.button_pressed = true

    if preferences.sprintMode == 1:
        gameData.sprintMode = 1
        sprintHold.button_pressed = true
        sprintToggle.button_pressed = false
    elif preferences.sprintMode == 2:
        gameData.sprintMode = 2
        sprintHold.button_pressed = false
        sprintToggle.button_pressed = true

    if preferences.leanMode == 1:
        gameData.leanMode = 1
        leanHold.button_pressed = true
        leanToggle.button_pressed = false
    elif preferences.leanMode == 2:
        gameData.leanMode = 2
        leanHold.button_pressed = false
        leanToggle.button_pressed = true

    if preferences.aimMode == 1:
        gameData.aimMode = 1
        aimHold.button_pressed = true
        aimToggle.button_pressed = false
    elif preferences.aimMode == 2:
        gameData.aimMode = 2
        aimHold.button_pressed = false
        aimToggle.button_pressed = true

func CreateActions():

    InputMap.load_from_project_settings()


    for item in actions.get_children():
        item.queue_free()


    for action in inputs:
        var button = remapButton.instantiate()
        var action_label = button.find_child("LabelAction")
        var input_label = button.find_child("LabelInput")


        action_label.text = inputs[action]


        var event = InputMap.action_get_events(action)


        if event.size() > 0:
            input_label.text = event[0].as_text().trim_suffix(" (Physical)")
        else:
            input_label.text = ""


        if preferences:


            if preferences.action_events.has(action):


                var savedEvent = preferences.action_events[action]


                InputMap.action_erase_events(action)
                InputMap.action_add_event(action, savedEvent)


                input_label.text = preferences.action_events[action].as_text().trim_suffix(" (Physical)")


        actions.add_child(button)


        button.pressed.connect(_on_input_pressed.bind(button, action))

func ResetActions():


    InputMap.load_from_project_settings()


    for item in actions.get_children():
        item.queue_free()


    for action in inputs:
        var button = remapButton.instantiate()
        var action_label = button.find_child("LabelAction")
        var input_label = button.find_child("LabelInput")


        action_label.text = inputs[action]


        var event = InputMap.action_get_events(action)


        if event.size() > 0:
            preferences.action_events[action] = event[0]


        if event.size() > 0:
            input_label.text = event[0].as_text().trim_suffix(" (Physical)")
        else:
            input_label.text = ""


        actions.add_child(button)


        button.pressed.connect(_on_input_pressed.bind(button, action))

    preferences.mouseMode = 1
    gameData.mouseMode = 1
    normal.button_pressed = true
    inverted.button_pressed = false

    preferences.sprintMode = 1
    gameData.sprintMode = 1
    sprintHold.button_pressed = true
    sprintToggle.button_pressed = false

    preferences.leanMode = 1
    gameData.leanMode = 1
    leanHold.button_pressed = true
    leanToggle.button_pressed = false

    preferences.aimMode = 1
    gameData.aimMode = 1
    aimHold.button_pressed = true
    aimToggle.button_pressed = false

    preferences.Save()

func _on_input_pressed(button, action):
    if !isRemapping:


        isRemapping = true


        actionToRemap = action
        buttonToRemap = button


        button.find_child("LabelInput").text = "Press key to bind..."
        PlayClick()

func _on_reset_pressed():
    ResetActions()
    PlayClick()

func _input(event):
    if isRemapping:
        if event is InputEventKey || (event is InputEventMouseButton && event.pressed):

            if event is InputEventMouseMotion && event.double_click:
                event.double_click = false


            InputMap.action_erase_events(actionToRemap)
            InputMap.action_add_event(actionToRemap, event)


            buttonToRemap.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


            preferences.action_events[actionToRemap] = event
            preferences.Save()


            isRemapping = false
            actionToRemap = false
            buttonToRemap = false

            accept_event()
            PlayClick()

func Deactivate():
    for item in actions.get_children():
        item.mouse_filter = MOUSE_FILTER_IGNORE

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

func _on_normal_pressed():
    gameData.mouseMode = 1
    preferences.mouseMode = 1
    preferences.Save()
    PlayClick()

func _on_inverted_pressed():
    gameData.mouseMode = 2
    preferences.mouseMode = 2
    preferences.Save()
    PlayClick()

func _on_sprint_hold_pressed():
    gameData.sprintMode = 1
    preferences.sprintMode = 1
    preferences.Save()
    PlayClick()

func _on_sprint_toggle_pressed():
    gameData.sprintMode = 2
    preferences.sprintMode = 2
    preferences.Save()
    PlayClick()

func _on_lean_hold_pressed():
    gameData.leanMode = 1
    preferences.leanMode = 1
    preferences.Save()
    PlayClick()

func _on_lean_toggle_pressed():
    gameData.leanMode = 2
    preferences.leanMode = 2
    preferences.Save()
    PlayClick()

func _on_aim_hold_pressed():
    gameData.aimMode = 1
    preferences.aimMode = 1
    preferences.Save()
    PlayClick()

func _on_aim_toggle_pressed():
    gameData.aimMode = 2
    preferences.aimMode = 2
    preferences.Save()
    PlayClick()
