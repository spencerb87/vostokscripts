extends Node3D
class_name LootContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("Container")
@export var containerName: String
@export var capacity = 0.0
@export var audioEvent: AudioEvent

@export_group("Loot")
@export var generate: bool
@export var lootTable: LootTable
@export var maxRoll = 100

@export_group("Debug")
@export var locked = false
@export var fill = false


var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]

var loot: Array[SlotData]
var UIManager

func _ready():
	if gameData.flycam:
		return

	UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")

	if lootTable != null && generate && !fill && !locked:
		ClearBuckets()
		FillBuckets()
		GenerateLoot()

	if lootTable != null && fill:
		DebugFill()

func ClearBuckets():
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
	var slotIndex = 0
	var availableSlots = 96
	var currentWeight = 0




	if rarityRoll <= 1:


		var legendaryPicks = randi_range(0, 1)


		if legendaryPicks > 0 && legendaryBucket.size() != 0:

			for pick in legendaryPicks:
				var randomPick = randi_range(0, legendaryBucket.size() - 1)
				var upcomingWeight = currentWeight + legendaryBucket[randomPick].weight

				if upcomingWeight < capacity && slotIndex < availableSlots:
					CreateLoot(legendaryBucket[randomPick], slotIndex)
					currentWeight += legendaryBucket[randomPick].weight
					slotIndex += 1




	if rarityRoll > 1 && rarityRoll <= 5:


		var rarePicks = randi_range(0, 2)


		if rarePicks > 0 && rareBucket.size() != 0:

			for pick in rarePicks:
				var randomPick = randi_range(0, rareBucket.size() - 1)
				var upcomingWeight = currentWeight + rareBucket[randomPick].weight

				if upcomingWeight < capacity && slotIndex < availableSlots:
					CreateLoot(rareBucket[randomPick], slotIndex)
					currentWeight += rareBucket[randomPick].weight
					slotIndex += 1




	if rarityRoll > 5 && rarityRoll <= 20:


		var uncommonPicks = randi_range(0, 4)


		if uncommonPicks > 0 && uncommonBucket.size() != 0:

			for pick in uncommonPicks:
				var randomPick = randi_range(0, uncommonBucket.size() - 1)
				var upcomingWeight = currentWeight + uncommonBucket[randomPick].weight

				if upcomingWeight < capacity && slotIndex < availableSlots:
					CreateLoot(uncommonBucket[randomPick], slotIndex)
					currentWeight += uncommonBucket[randomPick].weight
					slotIndex += 1




	if rarityRoll < 50:


		var commonPicks = randi_range(0, 4)


		if commonPicks > 0 && commonBucket.size() != 0:

			for pick in commonPicks:
				var randomPick = randi_range(0, commonBucket.size() - 1)
				var upcomingWeight = currentWeight + commonBucket[randomPick].weight

				if upcomingWeight < capacity && slotIndex < availableSlots:
					CreateLoot(commonBucket[randomPick], slotIndex)
					currentWeight += commonBucket[randomPick].weight
					slotIndex += 1

func DebugFill():
	var slotIndex = 0

	for index in 96:
		var randomPick = randi_range(0, lootTable.items.size() - 1)
		CreateLoot(lootTable.items[randomPick], slotIndex)
		slotIndex += 1

func Interact():
	if !locked:
		UIManager.OpenContainer(self)
		ContainerAudio()

func UpdateTooltip():
	if locked:
		gameData.tooltip = str(containerName + " [Locked]")
		return

	gameData.tooltip = str(containerName + " [Open]")







func ContainerAudio():
	var audio = audioInstance2D.instantiate()
	add_child(audio)
	audio.PlayInstance(audioEvent)

func CreateLoot(item: ItemData, slotIndex: int):
	var newSlotData = SlotData.new()
	newSlotData.itemData = item

	if item.type == "Ammunition":
		newSlotData.ammo = randi_range(1, newSlotData.itemData.boxSize)
	if item.type == "Armor":
		newSlotData.condition = randi_range(50, 100)
	elif item.type == "Weapon":
		newSlotData.ammo = randi_range(1, newSlotData.itemData.magazineSize)
		newSlotData.condition = randi_range(50, 100)


		if newSlotData.itemData.action == 2 || newSlotData.itemData.action == 3:
			newSlotData.chamber = 1

	newSlotData.index = slotIndex
	loot.append(newSlotData)

func Storage(containerGrid: GridContainer):

	loot.clear()

	var slotIndex = 0

	for containerSlot in containerGrid.get_children():
		if containerSlot.slotData.itemData:
			var newSlotData = SlotData.new()
			newSlotData.Update(containerSlot.slotData)
			newSlotData.index = slotIndex
			loot.append(newSlotData)

		slotIndex += 1
