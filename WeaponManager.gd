extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var flashSmall = preload("res://Resources/Flash_Small.tscn")
var flashMedium = preload("res://Resources/Flash_Medium.tscn")
var flashLarge = preload("res://Resources/Flash_Large.tscn")
var smoke = preload("res://Resources/Smoke.tscn")
var hit = preload("res://Resources/Hit.tscn")
var hitBlood = preload("res://Resources/Hit_Blood.tscn")
var hitKnife = preload("res://Resources/Hit_Knife.tscn")
var cartridgeRifle = preload("res://Resources/Cartridge_Rifle.tscn")
var cartridgePistol = preload("res://Resources/Cartridge_Pistol.tscn")
var cartridgeShell = preload("res://Resources/Cartridge_Shell.tscn")


@onready var interface = $"../../UI/UI_Interface"
@onready var preloader = $"../../Tools/Preloader"
@onready var camera = % Camera


var defaultGloves = preload("res://Items/Hands/Files/MT_Gloves_Work.tres")
var defaultSleeves = preload("res://Items/Torso/Jacket_Military_M62/Files/MT_Jacket_Military_M62_Sleeves.tres")


@onready var worldLight = $"../Flash/World"
@onready var FPSLight = $"../Flash/FPS"
var muzzleFlash = false
var flashTimer = 0.0


var drawTime = 0.2
var drawTimer = 0.0

var primarySlot
var secondarySlot
var knifeSlot
var torsoSlot
var handsSlot

func _ready():
    primarySlot = interface.equipmentGrid.get_child(0)
    secondarySlot = interface.equipmentGrid.get_child(1)
    knifeSlot = interface.equipmentGrid.get_child(12)
    torsoSlot = interface.equipmentGrid.get_child(6)
    handsSlot = interface.equipmentGrid.get_child(8)

func _physics_process(delta):
    MuzzleFlash(delta)

    if gameData.freeze || gameData.isInspecting || gameData.isSubmerged:
        return

    if gameData.isDrawing:
        drawTimer += delta

        if drawTimer > drawTime:
            gameData.isDrawing = false
            drawTimer = 0.0

    if Input.is_action_just_pressed(("primary")) && !gameData.isReloading && !gameData.isDrawing && !primarySlot.isOccupied:

        if primarySlot.isActive && preloader.get(str(primarySlot.slotData.itemData.file + "_Rig")):
            DrawPrimary()

    if Input.is_action_just_pressed(("secondary")) && !gameData.isReloading && !gameData.isDrawing && !secondarySlot.isOccupied:

        if secondarySlot.isActive && preloader.get(str(secondarySlot.slotData.itemData.file + "_Rig")):
            DrawSecondary()

    if Input.is_action_just_pressed(("knife")) && !gameData.isReloading && !gameData.isDrawing && !knifeSlot.isOccupied:

        if knifeSlot.isActive && preloader.get(str(knifeSlot.slotData.itemData.file + "_Rig")):
            DrawKnife()

func MuzzleFlash(delta):
    if muzzleFlash:
        flashTimer += delta


        worldLight.omni_range = 10.0
        FPSLight.omni_range = 2.0

        if gameData.TOD == 2:
            worldLight.light_energy = 0.2
            FPSLight.light_energy = 0.2
        else:
            worldLight.light_energy = 0.4
            FPSLight.light_energy = 0.4


        if flashTimer > 0.05:
            worldLight.omni_range = 0.0
            worldLight.light_energy = 0.0

            FPSLight.omni_range = 0.0
            FPSLight.light_energy = 0.0

            flashTimer = 0.0
            muzzleFlash = false

func DrawPrimary():
    if gameData.secondary:
        ClearCurrent()
        gameData.secondary = false

    if gameData.knife:
        ClearCurrent()
        gameData.knife = false

    gameData.primary = !gameData.primary
    gameData.isDrawing = true

    if gameData.primary:
        var newPrimary = preloader.get(str(primarySlot.slotData.itemData.file + "_Rig")).instantiate()

        add_child(newPrimary)
        UpdateClothing()
        UpdateAttachments()
        PlayEquip()
    else:
        ClearWeapons()
        PlayUnequip()

func DrawSecondary():
    if gameData.primary:
        ClearCurrent()
        gameData.primary = false

    if gameData.knife:
        ClearCurrent()
        gameData.knife = false

    gameData.secondary = !gameData.secondary
    gameData.isDrawing = true

    if gameData.secondary:
        var newSecondary = preloader.get(str(secondarySlot.slotData.itemData.file + "_Rig")).instantiate()

        add_child(newSecondary)
        UpdateClothing()
        UpdateAttachments()
        PlayEquip()
    else:
        ClearWeapons()
        PlayUnequip()

func DrawKnife():
    if gameData.primary:
        ClearCurrent()
        gameData.primary = false

    if gameData.secondary:
        ClearCurrent()
        gameData.secondary = false

    gameData.knife = !gameData.knife
    gameData.isDrawing = true

    if gameData.knife:
        var newKnife = preloader.get(str(knifeSlot.slotData.itemData.file + "_Rig")).instantiate()

        add_child(newKnife)
        UpdateClothing()
        UpdateAttachments()
        PlayEquip()
    else:
        ClearWeapons()
        PlayUnequip()

func ClearCurrent():
    var childCount = get_child_count()

    if childCount != 0:
        for n in get_children():
            remove_child(n)
            n.queue_free()

func ClearWeapons():
    var childCount = get_child_count()

    if childCount != 0:
        for n in get_children():
            remove_child(n)
            n.queue_free()

    gameData.primary = false
    gameData.secondary = false
    gameData.knife = false
    gameData.isDrawing = false
    gameData.isReloading = false
    gameData.isInspecting = false
    gameData.isPreparing = false
    gameData.isInserting = false
    gameData.isAiming = false
    gameData.isScoped = false
    gameData.aimFOV = gameData.baseFOV

func PlayEquip():
    var equip = audioInstance2D.instantiate()
    get_tree().get_root().add_child(equip)
    equip.PlayInstance(audioLibrary.equip)

func PlayUnequip():
    var unequip = audioInstance2D.instantiate()
    get_tree().get_root().add_child(unequip)
    unequip.PlayInstance(audioLibrary.unequip)

func UpdateClothing():
    if gameData.primary || gameData.secondary || gameData.knife:

        var arms = get_child(0).arms


        if torsoSlot.slotData.itemData:
            arms.set_surface_override_material(0, torsoSlot.slotData.itemData.material)
        else:
            arms.set_surface_override_material(0, defaultSleeves)

        if handsSlot.slotData.itemData:
            arms.set_surface_override_material(1, handsSlot.slotData.itemData.material)
        else:
            arms.set_surface_override_material(1, defaultGloves)

func UpdateAttachments():

    var weapon = get_child(0)

    if gameData.primary && weapon is Weapon:


        if primarySlot.slotData.muzzle:

            if weapon.attachments.get_child_count() != 0:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == primarySlot.slotData.muzzle.file:
                        weapon.activeMuzzle = attachment
                        attachment.visible = true


        if primarySlot.slotData.optic:

            if weapon.attachments.get_child_count() != 0:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == primarySlot.slotData.optic.file:
                        weapon.activeOptic = attachment
                        attachment.position.z += primarySlot.slotData.position
                        attachment.visible = true
                        weapon.UpdateAimOffset()


            if weapon.weaponData.useMount && !primarySlot.slotData.optic.hasMount:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == "Mount":
                        attachment.visible = true

    if gameData.secondary && weapon is Weapon:


        if secondarySlot.slotData.muzzle:

            if weapon.attachments.get_child_count() != 0:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == secondarySlot.slotData.muzzle.file:
                        weapon.activeMuzzle = attachment
                        attachment.visible = true


        if secondarySlot.slotData.optic:

            if weapon.attachments.get_child_count() != 0:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == secondarySlot.slotData.optic.file:
                        weapon.activeOptic = attachment
                        attachment.position.z += secondarySlot.slotData.position
                        attachment.visible = true
                        weapon.UpdateAimOffset()


            if weapon.weaponData.useMount && !secondarySlot.slotData.optic.hasMount:
                for attachment in weapon.attachments.get_children():
                    if attachment.name == "Mount":
                        attachment.visible = true

func LoadPrimary():
    var newPrimary = preloader.get(str(primarySlot.slotData.itemData.file + "_Rig")).instantiate()
    add_child(newPrimary)
    UpdateClothing()
    UpdateAttachments()

func LoadSecondary():
    var newSecondary = preloader.get(str(secondarySlot.slotData.itemData.file + "_Rig")).instantiate()
    add_child(newSecondary)
    UpdateClothing()
    UpdateAttachments()

func LoadKnife():
    var newKnife = preloader.get(str(knifeSlot.slotData.itemData.file + "_Rig")).instantiate()
    add_child(newKnife)
    UpdateClothing()
    UpdateAttachments()
