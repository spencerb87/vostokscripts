extends Panel

@export var slot: PackedScene
var interface: Interface
var taskData: TaskData
var isCompleted = false

@onready var highlight = $Highlight
@onready var taskName = $Name
@onready var status = $Status
@onready var deliverItems = $Elements / Deliver / Items
@onready var receiveItems = $Elements / Receive / Items
@onready var deliverGrid = $Elements / Deliver_Grid
@onready var receiveGrid = $Elements / Receive_Grid
@onready var deliveryButton = $Elements / GridContainer / Delivery
@onready var completeButton = $Elements / GridContainer / Complete

var normalColor = Color(0.0, 0.0, 0.0, 0.0)
var selectedColor = Color(1.0, 1.0, 1.0, 0.1)
var completedColor = Color(0.0, 1.0, 0.0, 0.1)

func SetTaskUI(task: TaskData, targetInterface: Interface):

    taskData = task


    taskName.text = taskData.name
    deliverItems.text = CreateDeliverString()
    receiveItems.text = CreateReceiveString()


    interface = targetInterface


    for item in deliverGrid.get_children():
        item.queue_free()


    for item in receiveGrid.get_children():
        item.queue_free()


    for itemData in taskData.deliver:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newSlot = slot.instantiate()
        deliverGrid.add_child(newSlot)

        newSlot.type = newSlot.SlotType.Display
        newSlot.ConnectInterface(interface)
        newSlot.SetSlotData(newSlotData)


    for itemData in taskData.receive:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newSlot = slot.instantiate()
        receiveGrid.add_child(newSlot)

        newSlot.type = newSlot.SlotType.Display
        newSlot.ConnectInterface(interface)
        newSlot.SetSlotData(newSlotData)

func CreateDeliverString() -> String:
    var string = ""
    var deliverSize = taskData.deliver.size()

    for itemData in taskData.deliver:
        string += String(itemData.abbreviation)
        deliverSize -= 1

        if deliverSize > 0:
            string += ", "

    return string

func CreateReceiveString() -> String:
    var string = ""
    var receiveSize = taskData.receive.size()

    for itemData in taskData.receive:
        string += String(itemData.abbreviation)
        receiveSize -= 1

        if receiveSize > 0:
            string += ", "

    return string

func AddDeliveryItem(itemData: ItemData):

    for deliverySlot in deliverGrid.get_children():

        if !deliverySlot.isDelivered:

            if itemData.name == deliverySlot.slotData.itemData.name:
                deliverySlot.Deliver()
                break

    if CanComplete():
        completeButton.disabled = false
    else:
        completeButton.disabled = true

func RemoveDeliveryItem(itemData: ItemData):

    for deliverySlot in deliverGrid.get_children():

        if deliverySlot.isDelivered:

            if itemData.name == deliverySlot.slotData.itemData.name:
                deliverySlot.ResetDelivery()
                break

    if CanComplete():
        completeButton.disabled = false
    else:
        completeButton.disabled = true

func ResetDeliverySlots():
    for deliverySlot in deliverGrid.get_children():
        deliverySlot.ResetDelivery()

func CanComplete() -> bool:
    var itemsDelivered = 0
    var itemsNeeded = deliverGrid.get_child_count()

    for deliverySlot in deliverGrid.get_children():
        if deliverySlot.isDelivered:
            itemsDelivered += 1

    if itemsDelivered == itemsNeeded:
        return true
    else:
        return false

func _on_delivery_toggled(toggled_on):
    if toggled_on:

        if interface.selectedTask:
            interface.selectedTask.ResetDeliverySlots()
            interface.selectedTask.Unlocked()


        Selected()
        interface.delivery = true
        interface.selectedTask = self
        interface.ClickAudio()

    else:


        if !isCompleted:


            Unlocked()
            ResetDeliverySlots()
            interface.ResetDelivery()
            interface.ClickAudio()

func _on_complete_pressed():

    Completed()


    interface.trader.CompleteTask(taskData)
    interface.TraderTaskAudio()


    interface.RemoveDeliveredItems()


    for deliverySlot in deliverGrid.get_children():
        deliverySlot.ResetDelivery()


    interface.GetTaskItems(self)
    interface.ResetDelivery()
    interface.UpdateTaskUI()
    interface.UpdateTraderInfo()
    interface.CalculateValues(false)

func Selected():
    isCompleted = false
    status.text = "Available"
    deliveryButton.text = "Stop Delivery"
    deliveryButton.disabled = false
    completeButton.disabled = true
    highlight.color = selectedColor

func Unlocked():
    isCompleted = false
    status.text = "Available"
    deliveryButton.text = "Start Delivery"
    deliveryButton.disabled = false
    completeButton.disabled = true
    highlight.color = normalColor

func Locked():
    isCompleted = false
    status.text = "Locked"
    status.add_theme_color_override("font_color", Color.RED)
    deliveryButton.text = "Start Delivery"
    deliveryButton.disabled = true
    completeButton.disabled = true
    highlight.color = normalColor

func Completed():
    isCompleted = true
    status.text = "Completed"
    status.add_theme_color_override("font_color", Color.GREEN)
    deliveryButton.text = "Delivered"
    deliveryButton.disabled = true
    completeButton.disabled = true
    highlight.color = completedColor
