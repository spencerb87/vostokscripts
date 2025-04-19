extends Panel

@export var slot: PackedScene

var interface: Interface
var recipeData: RecipeData
var isActive = false


@onready var recipeName = $Name
@onready var highlight = $Highlight
@onready var time = $Time / Value
@onready var elements = $Elements


@onready var workbench = $Proximity / Workbench
@onready var tester = $Proximity / Tester
@onready var heat = $Proximity / Heat


@onready var requiresItems = $Elements / Requires / Items
@onready var resultsItems = $Elements / Results / Items


@onready var requiresGrid = $Elements / Requires_Grid
@onready var resultsGrid = $Elements / Results_Grid


@onready var showButton = $Show
@onready var combineButton = $Elements / Buttons / Combine
@onready var craftButton = $Elements / Buttons / Craft


var normalColor = Color(0.0, 0.0, 0.0, 0.0)
var selectedColor = Color(1.0, 1.0, 1.0, 0.1)
var activeColor = Color(0.0, 1.0, 0.0, 0.1)

func SetRecipeUI(recipe: RecipeData, targetInterface: Interface):

    recipeData = recipe


    recipeName.text = recipeData.name
    var minutes = floor(recipeData.time / 60)
    var seconds = int(recipeData.time) % 60
    time.text = "%02d:%02d" % [minutes, seconds]


    interface = targetInterface


    SetProximity()
    UpdateProximity()


    if recipeData.locked:
        showButton.disabled = true
        showButton.text = "Locked"
        return


    requiresItems.text = CreateRequiresString()
    resultsItems.text = CreateResultsString()


    for item in requiresGrid.get_children():
        item.queue_free()


    for item in resultsGrid.get_children():
        item.queue_free()


    for itemData in recipeData.requires:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newSlot = slot.instantiate()
        requiresGrid.add_child(newSlot)

        newSlot.type = newSlot.SlotType.Display
        newSlot.ConnectInterface(interface)
        newSlot.SetSlotData(newSlotData)


    for itemData in recipeData.results:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newSlot = slot.instantiate()
        resultsGrid.add_child(newSlot)

        newSlot.type = newSlot.SlotType.Display
        newSlot.ConnectInterface(interface)
        newSlot.SetSlotData(newSlotData)

func CreateRequiresString() -> String:
    var string = ""
    var requiresSize = recipeData.requires.size()

    for itemData in recipeData.requires:
        string += String(itemData.abbreviation)
        requiresSize -= 1

        if requiresSize > 0:
            string += ", "

    return string

func CreateResultsString() -> String:
    var string = ""
    var resultsSize = recipeData.results.size()

    for itemData in recipeData.results:
        string += String(itemData.abbreviation)
        resultsSize -= 1

        if resultsSize > 0:
            string += ", "

    return string

func AddRequiresItem(itemData: ItemData):

    for requiresSlot in requiresGrid.get_children():

        if !requiresSlot.isCrafting:

            if itemData.name == requiresSlot.slotData.itemData.name:
                requiresSlot.Craft()
                break

    if CanComplete():
        craftButton.disabled = false
    else:
        craftButton.disabled = true

func RemoveRequiresItem(itemData: ItemData):

    for requiresSlot in requiresGrid.get_children():

        if requiresSlot.isCrafting:

            if itemData.name == requiresSlot.slotData.itemData.name:
                requiresSlot.ResetCrafting()
                break

    if CanComplete():
        craftButton.disabled = false
    else:
        craftButton.disabled = true

func CanComplete() -> bool:
    var itemsDelivered = 0
    var itemsNeeded = requiresGrid.get_child_count()

    for requiresSlot in requiresGrid.get_children():
        if requiresSlot.isCrafting:
            itemsDelivered += 1

    if itemsDelivered == itemsNeeded:
        return true
    else:
        return false

func _on_show_toggled(toggled_on):
    if toggled_on:
        elements.show()
        showButton.text = "Hide"
        custom_minimum_size = Vector2(0, 256)
        size = Vector2(512, 256)
    else:
        Default()
        elements.hide()
        showButton.text = "Show"
        combineButton.button_pressed = false
        custom_minimum_size = Vector2(0, 36)
        size = Vector2(512, 36)

func _on_combine_toggled(toggled_on):
    if toggled_on:

        if interface.selectedRecipe:
            interface.selectedRecipe.ResetRequiresSlots()
            interface.selectedRecipe.Default()


        Selected()
        interface.crafting = true
        interface.selectedRecipe = self

    elif !isActive:

        Default()
        ResetRequiresSlots()
        interface.ResetCrafting()

func _on_craft_pressed():

    Active()


    interface.Craft()


    combineButton.button_pressed = false


    for requiresSlot in requiresGrid.get_children():
        requiresSlot.ResetCrafting()

func ResetRequiresSlots():
    for requireSlot in requiresGrid.get_children():
        requireSlot.ResetCrafting()

func Default():
    combineButton.text = "Combine"
    highlight.color = normalColor

func Selected():
    combineButton.text = "Reset"
    highlight.color = selectedColor

func Active():
    isActive = true
    showButton.disabled = true
    combineButton.disabled = true
    craftButton.disabled = true
    combineButton.text = "Combine"
    highlight.color = activeColor

func Completed():
    isActive = false
    showButton.disabled = false
    combineButton.disabled = false
    craftButton.disabled = true
    combineButton.text = "Combine"
    highlight.color = normalColor

func SetProximity():
    if recipeData.workbench:
        workbench.show()
    else:
        workbench.hide()

    if recipeData.tester:
        tester.show()
    else:
        tester.hide()

    if recipeData.heat:
        heat.show()
    else:
        heat.hide()

func UpdateProximity():
    if recipeData.heat:
        if interface && interface.gameData.heat:
            heat.modulate = Color8(0, 255, 0, 255)
            combineButton.disabled = false
        else:
            heat.modulate = Color8(255, 255, 255, 64)
            combineButton.disabled = true

func _on_show_pressed():
    interface.ClickAudio()

func _on_combine_pressed():
    interface.ClickAudio()
