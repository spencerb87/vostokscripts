extends CanvasLayer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var screen = $Screen
@onready var overlay = $Overlay
@onready var animation = $Animation
@onready var label = $Screen / Label
@onready var circle = $Screen / Circle


const Menu = "res://Scenes/Menu.tscn"
const Death = "res://Scenes/Death.tscn"
const Tutorial = "res://Scenes/Tutorial.tscn"
const Village = "res://Scenes/Village.scn"
const Shipyard = "res://Scenes/Shipyard.scn"
const Highway = "res://Scenes/Highway.scn"
const Minefield = "res://Scenes/Minefield.scn"
const Radar = "res://Scenes/Radar.scn"
const Attic = "res://Scenes/Attic.tscn"

@export var initials: Array[ItemData]
var scenePath: String

var masterBus = AudioServer.get_bus_index("Master")
var masterAmplify: AudioEffectAmplify = AudioServer.get_bus_effect(0, 1)
var masterValue = 0.0
var masterActive = false

func _ready():
    masterAmplify.volume_db = linear_to_db(0)



func CreateVersion():

    var version: Version = Version.new()

    version.name = "RTV_PD2_V2"

    ResourceSaver.save(version, "user://Version.tres")
    print("Version created: RTV_PD2_V2")

func CheckVersion() -> bool:

    var version: Version


    if !FileAccess.file_exists("user://Version.tres"):

        return false
    else:

        version = load("user://Version.tres") as Version


        if version.name == "RTV_PD2_V2":

            return true

    return false

func CheckShelter() -> bool:
    if FileAccess.file_exists("user://Shelter.tres"):
        return true
    else:
        return false



func LoadScene(scene: String):
    FadeInLoading()
    HideCursor()
    gameData.freeze = true

    if scene == "Menu":
        scenePath = Menu
        label.hide()
        circle.hide()
    elif scene == "Death":
        scenePath = Death
        label.hide()
        circle.hide()
    elif scene == "Tutorial":
        scenePath = Tutorial
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = true
        label.show()
        circle.show()
    elif scene == "Village":
        scenePath = Village
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false
        label.show()
        circle.show()
    elif scene == "Shipyard":
        scenePath = Shipyard
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false
        label.show()
        circle.show()
    elif scene == "Highway":
        scenePath = Highway
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false
        label.show()
        circle.show()
    elif scene == "Minefield":
        scenePath = Minefield
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false
        label.show()
        circle.show()
    elif scene == "Radar":
        scenePath = Radar
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = true
        gameData.tutorial = false
        label.show()
        circle.show()
    elif scene == "Attic":
        scenePath = Attic
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false
        label.show()
        circle.show()

    if label.visible && !gameData.flycam:
        label.text = "Loading " + scene + "..."
    elif label.visible && gameData.flycam:
        label.text = "Loading " + scene + " (Flycam)" + "..."

    await get_tree().create_timer(2.0).timeout;
    get_tree().change_scene_to_file(scenePath)



func ResetSave():
    var character: CharacterSave = CharacterSave.new()
    var shelter: ShelterSave = ShelterSave.new()
    var generalist: TraderSave = TraderSave.new()
    var doctor: TraderSave = TraderSave.new()

    var initialIndex = 0


    for initial in initials:
        var newSlotData = SlotData.new()
        newSlotData.itemData = initial
        newSlotData.index = initialIndex

        if initial.type == "Ammunition":
            newSlotData.ammo = initial.boxSize

        character.inventory.append(newSlotData)
        initialIndex += 1


    character.health = 100.0
    character.energy = 100.0
    character.hydration = 100.0
    character.temperature = 100.0
    character.bodyStamina = 100.0
    character.armStamina = 100.0
    character.overweight = false
    character.starvation = false
    character.dehydration = false
    character.bleeding = false
    character.fracture = false
    character.burn = false
    character.rupture = false
    character.primary = false
    character.secondary = false
    character.weaponPosition = 1


    generalist.levelProgression.resize(10)
    doctor.levelProgression.resize(10)


    ResourceSaver.save(character, "user://Character.tres")
    ResourceSaver.save(shelter, "user://Shelter.tres")
    ResourceSaver.save(generalist, "user://Generalist.tres")
    ResourceSaver.save(doctor, "user://Doctor.tres")
    print("RESET: SAVE")

func ResetGear():

    if !FileAccess.file_exists("user://Character.tres"):
        return

    var character: CharacterSave = load("user://Character.tres") as CharacterSave


    if character.inventory.size() != 0:
        character.inventory.clear()


    if character.equipment.size() != 0:
        character.equipment.clear()


    character.health = 100.0
    character.energy = 100.0
    character.hydration = 100.0
    character.temperature = 100.0
    character.bodyStamina = 100.0
    character.armStamina = 100.0
    character.overweight = false
    character.starvation = false
    character.dehydration = false
    character.bleeding = false
    character.fracture = false
    character.burn = false
    character.rupture = false
    character.headshot = false
    character.primary = false
    character.secondary = false
    character.weaponPosition = 1

    ResourceSaver.save(character, "user://Character.tres")
    print("RESET: Gear")



func SaveCharacter():
    var character: CharacterSave = CharacterSave.new()

    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")



    var inventorySlotIndex = 0

    for inventorySlot in interface.inventoryGrid.get_children():
        if inventorySlot.slotData.itemData:
            var newSlotData = SlotData.new()
            newSlotData.Update(inventorySlot.slotData)
            newSlotData.index = inventorySlotIndex
            character.inventory.append(newSlotData)

        inventorySlotIndex += 1




    var equipmentSlotIndex = 0

    for equipmentSlot in interface.equipmentGrid.get_children():
        if equipmentSlot.slotData.itemData:
            var newSlotData = SlotData.new()
            newSlotData.Update(equipmentSlot.slotData)
            newSlotData.index = equipmentSlotIndex
            character.equipment.append(newSlotData)

        equipmentSlotIndex += 1




    character.health = gameData.health
    character.energy = gameData.energy
    character.hydration = gameData.hydration
    character.temperature = gameData.temperature
    character.bodyStamina = gameData.bodyStamina
    character.armStamina = gameData.armStamina
    character.overweight = gameData.overweight
    character.starvation = gameData.starvation
    character.dehydration = gameData.dehydration
    character.bleeding = gameData.bleeding
    character.fracture = gameData.fracture
    character.burn = gameData.burn
    character.rupture = gameData.rupture
    character.headshot = gameData.headshot

    character.primary = gameData.primary
    character.secondary = gameData.secondary
    character.knife = gameData.knife
    character.weaponPosition = gameData.weaponPosition
    character.flashlight = gameData.flashlight
    character.NVG = gameData.NVG

    ResourceSaver.save(character, "user://Character.tres")
    print("SAVE: Character")

func LoadCharacter():

    if !FileAccess.file_exists("user://Character.tres"):
        return

    var character: CharacterSave = load("user://Character.tres") as CharacterSave


    var weaponManager = get_tree().current_scene.get_node("/root/Map/Core/Camera/Weapons")
    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")
    var flashlight = get_tree().current_scene.get_node("/root/Map/Core/Camera/Flashlight")
    var NVG = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_NVG")


    if character.inventory.size() != 0:
        for slotData: SlotData in character.inventory:
            interface.inventoryGrid.get_child(slotData.index).SetSlotData(slotData)


    if character.equipment.size() != 0:
        for slotData: SlotData in character.equipment:
            interface.equipmentGrid.get_child(slotData.index).SetSlotData(slotData)
            interface.equipmentGrid.get_child(slotData.index).HideHint()
            interface.UpdateLayer(slotData.itemData, true)


    gameData.health = character.health
    gameData.energy = character.energy
    gameData.hydration = character.hydration
    gameData.temperature = character.temperature
    gameData.bodyStamina = character.bodyStamina
    gameData.armStamina = character.armStamina
    gameData.overweight = character.overweight
    gameData.starvation = character.starvation
    gameData.dehydration = character.dehydration
    gameData.bleeding = character.bleeding
    gameData.fracture = character.fracture
    gameData.burn = character.burn
    gameData.rupture = character.rupture
    gameData.headshot = character.headshot

    gameData.primary = character.primary
    gameData.secondary = character.secondary
    gameData.knife = character.knife
    gameData.flashlight = character.flashlight
    gameData.NVG = character.NVG


    if gameData.primary && interface.equipmentGrid.get_child(0).slotData.itemData:
        weaponManager.LoadPrimary()
        gameData.weaponPosition = character.weaponPosition
    elif gameData.secondary && interface.equipmentGrid.get_child(1).slotData.itemData:
        weaponManager.LoadSecondary()
        gameData.weaponPosition = character.weaponPosition
    elif gameData.knife && interface.equipmentGrid.get_child(12).slotData.itemData:
        weaponManager.LoadKnife()


    NVG.Load()
    flashlight.Load()

    print("LOAD: Character")



func SaveShelter():


    var shelter: ShelterSave = ShelterSave.new()



    var containers = get_tree().get_nodes_in_group("Container")
    var containerIndex = 0


    for container in containers:
        var newContainerSave = ContainerSave.new()
        shelter.containers.append(newContainerSave)


    for container in containers:

        shelter.containers[containerIndex].name = container.name

        for slotData: SlotData in container.loot:
            shelter.containers[containerIndex].items.append(slotData)

        containerIndex += 1




    var items = get_tree().get_nodes_in_group("Item")
    var itemIndex = 0


    for item in items:
        var newItemSave = ItemSave.new()
        shelter.items.append(newItemSave)

    for item in items:
        shelter.items[itemIndex].name = item.name
        shelter.items[itemIndex].slotData = item.slotData
        shelter.items[itemIndex].position = item.get_child(0).global_position
        shelter.items[itemIndex].rotation = item.get_child(0).global_rotation

        itemIndex += 1




    ResourceSaver.save(shelter, "user://Shelter.tres")
    print("SAVE: Shelter")

func LoadShelter():

    if !FileAccess.file_exists("user://Shelter.tres"):
        return


    var shelter: ShelterSave = load("user://Shelter.tres") as ShelterSave




    var containers = get_tree().get_nodes_in_group("Container")


    for container in containers:


        for containerSave in shelter.containers:


            if container.name == containerSave.name:

                for slotData: SlotData in containerSave.items:
                    if slotData.itemData:
                        container.loot.append(slotData)




    for itemSave in shelter.items:

        var preloader = get_tree().current_scene.get_node("/root/Map/Core/Tools/Preloader")
        var file = preloader.get(itemSave.slotData.itemData.file)

        if file:
            var pickup = preloader.get(itemSave.slotData.itemData.file).instantiate()
            var map = get_tree().current_scene.get_node("/root/Map")
            map.add_child(pickup)
            pickup.slotData = itemSave.slotData
            pickup.Freeze()
            pickup.UpdateAttachments()
            pickup.get_child(0).global_position = itemSave.position
            pickup.get_child(0).global_rotation = itemSave.rotation
        else:
            print("File not found: " + itemSave.slotData.itemData.name)



    print("LOAD: Shelter")



func SaveTrader(trader: String):

    if gameData.tutorial:
        return


    var traderSave: TraderSave = TraderSave.new()


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")


    for taskString in interface.trader.tasksCompleted:
        traderSave.tasksCompleted.append(taskString)


    for levelVector in interface.trader.levelProgression:
        traderSave.levelProgression.append(levelVector)


    if trader == "Generalist":
        ResourceSaver.save(traderSave, "user://Generalist.tres")
        print("SAVE: Generalist")


    elif trader == "Doctor":
        ResourceSaver.save(traderSave, "user://Doctor.tres")
        print("SAVE: Doctor")

func LoadTrader(trader: String):

    if gameData.tutorial:
        return


    var traderSave: TraderSave


    if trader == "Generalist":
        if !FileAccess.file_exists("user://Generalist.tres"):
            return
        else:
            traderSave = load("user://Generalist.tres") as TraderSave
            print("LOAD: Generalist")


    if trader == "Doctor":
        if !FileAccess.file_exists("user://Doctor.tres"):
            return
        else:
            traderSave = load("user://Doctor.tres") as TraderSave
            print("LOAD: Doctor")


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/UI_Interface")


    interface.trader.tasksCompleted.clear()


    interface.trader.levelProgression.clear()


    for taskString in traderSave.tasksCompleted:
        interface.trader.tasksCompleted.append(taskString)


    for levelVector in traderSave.levelProgression:
        interface.trader.levelProgression.append(levelVector)




func _physics_process(delta):
    if masterActive:
        masterValue = move_toward(masterValue, 1.0, delta / 2.0)
    else:
        masterValue = move_toward(masterValue, 0.0, delta / 2.0)

    masterAmplify.volume_db = linear_to_db(masterValue)

func FadeIn():
    PlayTransition()
    animation.play("Fade_In")
    masterActive = false

func FadeOut():
    animation.play("Fade_Out")
    await get_tree().create_timer(1).timeout;
    masterActive = true

func FadeInLoading():
    PlayTransition()
    animation.play("Fade_In_Loading")
    masterActive = false

func FadeOutLoading():
    animation.play("Fade_Out_Loading")
    await get_tree().create_timer(1).timeout;
    masterActive = true

func ShowLoadingScreen():
    screen.show()

func HideLoadingScreen():
    screen.hide()

func ShowOverlay():
    overlay.show()

func HideOverlay():
    overlay.hide()



func PlayTransition():
    var transition = audioInstance2D.instantiate()
    add_child(transition)
    transition.PlayInstance(audioLibrary.transition)

func HideCursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func ShowCursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func Quit():
    FadeIn()
    HideCursor()
    await get_tree().create_timer(2.0).timeout;
    get_tree().quit()
