extends Node3D
class_name Trader


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var traderData: TraderData
var level: int
var tax: int
var tasksCompleted: Array[String]
var levelProgression: Array[Vector2]
var supply: Array[SlotData]


var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]


var weapons: Array[ItemData]
var attachments: Array[ItemData]
var ammunitions: Array[ItemData]
var equipments: Array[ItemData]
var consumables: Array[ItemData]
var medicals: Array[ItemData]
var electronics: Array[ItemData]
var miscs: Array[ItemData]


@onready var animations = $Trader / Animations
@onready var timer = $Timer

var resupply = false
var UIManager

func _ready():
    if gameData.flycam:

        await get_tree().create_timer(randi_range(0, 4)).timeout;
        animations.play("Trader_Idle")
    else:

        timer.wait_time = traderData.resupply * 60
        timer.start()


        await get_tree().create_timer(randi_range(0, 4)).timeout;
        animations.play("Trader_Idle")


        levelProgression.resize(10)
        UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")


        if traderData.lootTable != null:
            ClearArrays()
            FillBuckets()
            GenerateItems()
            CreateSupply()

func _physics_process(_delta):
    if timer.is_stopped() && !gameData.flycam:
        ClearArrays()
        FillBuckets()
        GenerateItems()
        CreateSupply()
        timer.start()
        resupply = true

func ClearArrays():
    commonBucket.clear()
    uncommonBucket.clear()
    rareBucket.clear()
    legendaryBucket.clear()
    weapons.clear()
    attachments.clear()
    ammunitions.clear()
    equipments.clear()
    consumables.clear()
    medicals.clear()
    electronics.clear()
    miscs.clear()
    supply.clear()

func FillBuckets():
    if traderData.lootTable.items.size() != 0:

        for item in traderData.lootTable.items:
            if item.rarity == item.ItemRarity.Common:
                commonBucket.append(item)
            elif item.rarity == item.ItemRarity.Uncommon:
                uncommonBucket.append(item)
            elif item.rarity == item.ItemRarity.Rare:
                rareBucket.append(item)
            elif item.rarity == item.ItemRarity.Legendary:
                legendaryBucket.append(item)

func GenerateItems():

    var rarityRoll = randi_range(0, 20)




    if rarityRoll <= 1:


        var legendaryPicks = randi_range(1, 5)


        if legendaryPicks > 0 && legendaryBucket.size() != 0:

            for pick in legendaryPicks:
                var randomPick = randi_range(0, legendaryBucket.size() - 1)
                SortItem(legendaryBucket[randomPick])




    if rarityRoll <= 5:


        var rarePicks = randi_range(1, 10)


        if rarePicks > 0 && rareBucket.size() != 0:

            for pick in rarePicks:
                var randomPick = randi_range(0, rareBucket.size() - 1)
                SortItem(rareBucket[randomPick])




    if rarityRoll <= 20:


        var uncommonPicks = randi_range(10, 20)


        if uncommonPicks > 0 && uncommonBucket.size() != 0:

            for pick in uncommonPicks:
                var randomPick = randi_range(0, uncommonBucket.size() - 1)
                SortItem(uncommonBucket[randomPick])




    if rarityRoll <= 50:


        var commonPicks = randi_range(20, 40)


        if commonPicks > 0 && commonBucket.size() != 0:

            for pick in commonPicks:
                var randomPick = randi_range(0, commonBucket.size() - 1)
                SortItem(commonBucket[randomPick])

func SortItem(item: ItemData):
    if item.type == "Weapon":
        weapons.append(item)
    elif item.type == "Attachment":
        attachments.append(item)
    elif item.type == "Ammunition":
        ammunitions.append(item)
    elif item.type == "Medical":
        medicals.append(item)
    elif item.type == "Consumable":
        consumables.append(item)
    elif item.type == "Equipment":
        equipments.append(item)
    elif item.type == "Electronics":
        electronics.append(item)
    elif item.type == "Misc":
        miscs.append(item)

func CreateSupply():
    var supplyLimit = 48

    var weaponLimit = 5
    var attachmentLimit = 5
    var ammunitionLimit = 5
    var medicalLimit = 5
    var equipmentLimit = 5
    var consumableLimit = 5
    var electronicsLimit = 5
    var miscLimit = 5

    for item in weapons:
        if supplyLimit == 0 || weaponLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        weaponLimit -= 1

    for item in attachments:
        if supplyLimit == 0 || attachmentLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        attachmentLimit -= 1

    for item in ammunitions:
        if supplyLimit == 0 || ammunitionLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        newSlotData.ammo = newSlotData.itemData.boxSize
        supply.append(newSlotData)
        supplyLimit -= 1
        ammunitionLimit -= 1

    for item in medicals:
        if supplyLimit == 0 || medicalLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        medicalLimit -= 1

    for item in equipments:
        if supplyLimit == 0 || equipmentLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        equipmentLimit -= 1

    for item in consumables:
        if supplyLimit == 0 || consumableLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        consumableLimit -= 1

    for item in electronics:
        if supplyLimit == 0 || electronicsLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        electronicsLimit -= 1

    for item in miscs:
        if supplyLimit == 0 || miscLimit == 0:
            break

        var newSlotData = SlotData.new()
        newSlotData.itemData = item
        supply.append(newSlotData)
        supplyLimit -= 1
        miscLimit -= 1

func RemoveFromSupply(item: ItemData):
    for slotData in supply:
        if slotData.itemData.name == item.name:
            supply.erase(slotData)
            break

func Interact():
    UIManager.OpenTrader(self)

func UpdateTooltip():
    gameData.tooltip = str(traderData.name + " [Trade]")

func CompleteTask(taskData: TaskData):

    var taskString: String
    taskString = taskData.name


    tasksCompleted.append(taskString)




    var levelIndex = taskData.level - 1


    var levelTasks = traderData.levels[levelIndex].tasks.size()


    levelProgression[levelIndex].x += 1


    if levelProgression[levelIndex].x == levelTasks:

        levelProgression[levelIndex].y = 1
    else:

        levelProgression[levelIndex].y = 0
