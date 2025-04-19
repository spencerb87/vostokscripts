extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export_group("Loot")
@export var lootTable: LootTable
@export var maxRoll = 100
@export var generate = false


var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]

var loot: Array[ItemData]
var preloader

func _ready():
    var gizmo = get_child(0)
    gizmo.hide()

    if gameData.flycam:
        return

    preloader = get_tree().current_scene.get_node("/root/Map/Core/Tools/Preloader")

    if generate && lootTable != null:
        Clear()
        FillBuckets()
        GenerateLoot()
        SpawnPickups()

func Clear():
    commonBucket.clear()
    uncommonBucket.clear()
    rareBucket.clear()
    legendaryBucket.clear()

func FillBuckets():
    if lootTable.items.size() != 0:

        for item in lootTable.items:
            if item.rarity == item.ItemRarity.Common:
                commonBucket.append(item)
            elif item.rarity == item.ItemRarity.Uncommon:
                uncommonBucket.append(item)
            elif item.rarity == item.ItemRarity.Rare:
                rareBucket.append(item)
            elif item.rarity == item.ItemRarity.Legendary:
                legendaryBucket.append(item)

func GenerateLoot():

    var rarityRoll = randi_range(0, maxRoll)




    if rarityRoll <= 1:


        var legendaryPicks = randi_range(0, 2)


        if legendaryPicks > 0 && legendaryBucket.size() != 0:

            for pick in legendaryPicks:
                var randomPick = randi_range(0, legendaryBucket.size() - 1)
                loot.append(legendaryBucket[randomPick])




    if rarityRoll > 1 && rarityRoll <= 5:


        var rarePicks = randi_range(0, 2)


        if rarePicks > 0 && rareBucket.size() != 0:

            for pick in rarePicks:
                var randomPick = randi_range(0, rareBucket.size() - 1)
                loot.append(rareBucket[randomPick])




    if rarityRoll > 5 && rarityRoll <= 20:


        var uncommonPicks = randi_range(0, 4)


        if uncommonPicks > 0 && uncommonBucket.size() != 0:

            for pick in uncommonPicks:
                var randomPick = randi_range(0, uncommonBucket.size() - 1)
                loot.append(uncommonBucket[randomPick])




    if rarityRoll < 50:


        var commonPicks = randi_range(0, 4)


        if commonPicks > 0 && commonBucket.size() != 0:

            for pick in commonPicks:
                var randomPick = randi_range(0, commonBucket.size() - 1)
                loot.append(commonBucket[randomPick])

func SpawnPickups():
    for itemData in loot:
        if itemData:

            if preloader.get(itemData.file):

                var pickup = preloader.get(itemData.file).instantiate()
                add_child(pickup)

                var dropDirection = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

                pickup.Unfreeze()
                pickup.SetDropVelocity(dropDirection, 10.0)

                var newSlotData = SlotData.new()
                newSlotData.itemData = itemData

                if itemData.type == "Ammunition":
                    newSlotData.ammo = randi_range(1, newSlotData.itemData.boxSize)
                elif itemData.type == "Armor":
                    newSlotData.condition = randi_range(50, 100)
                elif itemData.type == "Weapon":
                    newSlotData.ammo = randi_range(1, newSlotData.itemData.magazineSize)
                    newSlotData.condition = randi_range(50, 100)


                    if newSlotData.itemData.action == 2 || newSlotData.itemData.action == 3:
                        newSlotData.chamber = 1

                pickup.slotData = newSlotData
