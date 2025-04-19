extends Control

var interface


@onready var content = $Content
@onready var panel = $Content / Panel
@onready var title = $Content / Panel / Margin / VBox / Title
@onready var type = $Content / Panel / Margin / VBox / Type
@onready var separator = $Content / Panel / Margin / VBox / Separator
@onready var weight = $Content / Panel / Margin / VBox / Weight
@onready var value = $Content / Panel / Margin / VBox / Value
@onready var condition = $Content / Panel / Margin / VBox / Condition
@onready var use = $Content / Panel / Margin / VBox / Use
@onready var damage = $Content / Panel / Margin / VBox / Damage
@onready var caliber = $Content / Panel / Margin / VBox / Caliber
@onready var magazine = $Content / Panel / Margin / VBox / Magazine
@onready var capacity = $Content / Panel / Margin / VBox / Capacity
@onready var stack = $Content / Panel / Margin / VBox / Stack
@onready var armor = $Content / Panel / Margin / VBox / Armor
@onready var health = $Content / Panel / Margin / VBox / Health
@onready var energy = $Content / Panel / Margin / VBox / Energy
@onready var hydration = $Content / Panel / Margin / VBox / Hydration
@onready var temperature = $Content / Panel / Margin / VBox / Temperature
@onready var cures = $Content / Panel / Margin / VBox / Cures
@onready var compatibility = $Content / Panel / Margin / VBox / Compatibility
@onready var list = $Content / Panel / Margin / VBox / List
@onready var info = $Content / Panel / Margin / VBox / Info


@onready var weightValue = $Content / Panel / Margin / VBox / Weight / Value
@onready var valueValue = $Content / Panel / Margin / VBox / Value / Value
@onready var conditionValue = $Content / Panel / Margin / VBox / Condition / Value
@onready var useValue = $Content / Panel / Margin / VBox / Use / Value
@onready var damageValue = $Content / Panel / Margin / VBox / Damage / Value
@onready var caliberValue = $Content / Panel / Margin / VBox / Caliber / Value
@onready var magazineValue = $Content / Panel / Margin / VBox / Magazine / Value
@onready var capacityValue = $Content / Panel / Margin / VBox / Capacity / Value
@onready var stackValue = $Content / Panel / Margin / VBox / Stack / Value
@onready var armorValue = $Content / Panel / Margin / VBox / Armor / Value
@onready var healthValue = $Content / Panel / Margin / VBox / Health / Value
@onready var energyValue = $Content / Panel / Margin / VBox / Energy / Value
@onready var hydrationValue = $Content / Panel / Margin / VBox / Hydration / Value
@onready var temperatureValue = $Content / Panel / Margin / VBox / Temperature / Value


@onready var overweight = $Content / Panel / Margin / VBox / Cures / Icons / Overweight
@onready var starvation = $Content / Panel / Margin / VBox / Cures / Icons / Starvation
@onready var dehydration = $Content / Panel / Margin / VBox / Cures / Icons / Dehydration
@onready var bleeding = $Content / Panel / Margin / VBox / Cures / Icons / Bleeding
@onready var fracture = $Content / Panel / Margin / VBox / Cures / Icons / Fracture
@onready var hypothermia = $Content / Panel / Margin / VBox / Cures / Icons / Hypothermia
@onready var burn = $Content / Panel / Margin / VBox / Cures / Icons / Burn
@onready var poisoning = $Content / Panel / Margin / VBox / Cures / Icons / Poisoning
@onready var radiation = $Content / Panel / Margin / VBox / Cures / Icons / Radiation
@onready var rupture = $Content / Panel / Margin / VBox / Cures / Icons / Rupture
@onready var headshot = $Content / Panel / Margin / VBox / Cures / Icons / Headshot

func _ready():
    interface = owner
    Reset()

func Reset():
    title.text = "Hover to activate"
    type.hide()
    separator.hide()
    weight.hide()
    value.hide()
    condition.hide()
    use.hide()
    damage.hide()
    caliber.hide()
    magazine.hide()
    capacity.hide()
    stack.hide()
    armor.hide()
    health.hide()
    energy.hide()
    hydration.hide()
    temperature.hide()

    overweight.hide()
    starvation.hide()
    dehydration.hide()
    bleeding.hide()
    fracture.hide()
    hypothermia.hide()
    burn.hide()
    poisoning.hide()
    radiation.hide()
    rupture.hide()

    cures.hide()
    compatibility.hide()
    list.hide()
    info.hide()

    panel.size = Vector2(0, 0)
    interface.tooltipOffset = panel.size.y

func Update(slotData: SlotData):

    type.show()
    separator.show()
    weight.show()
    value.show()


    condition.hide()
    use.hide()
    damage.hide()
    caliber.hide()
    magazine.hide()
    capacity.hide()
    health.hide()
    energy.hide()
    hydration.hide()
    temperature.hide()
    cures.hide()
    overweight.hide()
    starvation.hide()
    dehydration.hide()
    bleeding.hide()
    fracture.hide()
    hypothermia.hide()
    burn.hide()
    poisoning.hide()
    radiation.hide()
    rupture.hide()
    headshot.hide()


    Condition(slotData)


    title.text = slotData.itemData.name
    type.text = slotData.itemData.type + " (" + str(slotData.itemData.ItemRarity.find_key(slotData.itemData.rarity)) + ")"
    weightValue.text = str(CalculateWeight(slotData)) + "kg"
    valueValue.text = str(CalculateValue(slotData)) + "€"

    if slotData.itemData.type == "Weapon":
        damage.show()
        caliber.show()
        magazine.show()

        damageValue.text = str(slotData.itemData.damage)
        caliberValue.text = str(slotData.itemData.caliber)
        magazineValue.text = str(slotData.itemData.magazineSize) + "-round"

    elif slotData.itemData.type == "Knife":
        damage.show()
        damageValue.text = str(slotData.itemData.damage)

    elif slotData.itemData.type == "Ammunition":
        stack.show()
        stackValue.text = str(slotData.itemData.maxStack)

        compatibility.show()
        list.show()
        list.text = slotData.itemData.compatibility

    elif slotData.itemData.type == "Attachment":
        compatibility.show()
        list.show()
        list.text = slotData.itemData.compatibility

    elif slotData.itemData.type == "Equipment":


        if slotData.itemData.capacity != 0:
            capacity.show()
            capacityValue.text = "+" + str(slotData.itemData.capacity) + "kg"


        if slotData.itemData.helmet:
            armor.show()
            armorValue.text = "NIJ " + slotData.itemData.rating


        if slotData.itemData.carrier:

            if slotData.armor:
                armor.show()
                armorValue.text = "NIJ " + slotData.armor.rating

            else:
                armor.show()
                armorValue.text = "Compatible"

    elif slotData.itemData.type == "Armor":
        armor.show()
        armorValue.text = "NIJ " + slotData.itemData.rating

    elif slotData.itemData.type == "Consumable" || slotData.itemData.type == "Medical":
        use.show()
        useValue.text = str(slotData.itemData.time) + "s"

        if slotData.itemData.health != 0:
            health.show()
        if slotData.itemData.energy != 0:
            energy.show()
            starvation.show()
        if slotData.itemData.hydration != 0:
            hydration.show()
            dehydration.show()
        if slotData.itemData.temperature != 0:
            temperature.show()
            hypothermia.show()

        if slotData.itemData.bleeding:
            cures.show()
            bleeding.show()
        if slotData.itemData.fracture:
            cures.show()
            fracture.show()
        if slotData.itemData.burn:
            cures.show()
            burn.show()
        if slotData.itemData.rupture:
            cures.show()
            rupture.show()
        if slotData.itemData.headshot:
            cures.show()
            headshot.show()

        healthValue.text = "+" + str(slotData.itemData.health)
        energyValue.text = "+" + str(slotData.itemData.energy)
        hydrationValue.text = "+" + str(slotData.itemData.hydration)
        temperatureValue.text = "+" + str(slotData.itemData.temperature)


    panel.size = Vector2(256, 0)
    interface.tooltipOffset = panel.size.y

func CalculateValue(slotData: SlotData) -> int:

    if slotData.itemData.type == "Ammunition":
        var percentage = float(slotData.ammo) / float(slotData.itemData.boxSize)
        return int(slotData.itemData.value * percentage)

    elif slotData.itemData.type == "Armor":
        return int(slotData.itemData.value * (slotData.condition * 0.01))

    elif slotData.itemData.type == "Equipment" && slotData.armor:
        return int(slotData.itemData.value + (slotData.armor.value * (slotData.condition * 0.01)))

    else:
        return int(slotData.itemData.value * (slotData.condition * 0.01))

func CalculateWeight(slotData: SlotData) -> float:

    if slotData.itemData.type == "Ammunition":
        var percentage = float(slotData.ammo) / float(slotData.itemData.boxSize)
        return float(snappedf(slotData.itemData.weight * percentage, 0.01))

    if slotData.itemData.type == "Equipment" && slotData.armor:
        return float(snappedf(slotData.itemData.weight + slotData.armor.weight, 0.01))

    else:
        return float(snappedf(slotData.itemData.weight, 0.01))

func Condition(slotData: SlotData):

    if slotData.itemData.type == "Knife":
        condition.show()

    elif slotData.itemData.type == "Armor":
        condition.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.carrier && slotData.armor:
        condition.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.helmet:
        condition.show()

    elif slotData.itemData.type == "Weapon":
        condition.show()
    else:
        condition.hide()


    if condition.visible:
        if slotData.condition <= 25:
            conditionValue.add_theme_color_override("font_color", Color.RED)
        elif slotData.condition <= 50 && slotData.condition > 25:
            conditionValue.add_theme_color_override("font_color", Color.YELLOW)
        else:
            conditionValue.add_theme_color_override("font_color", Color.GREEN)

        conditionValue.text = str(slotData.condition) + "%"

func ConditionColor(slotData: SlotData):
    if slotData.condition <= 25:
        conditionValue.add_theme_color_override("font_color", Color.RED)
    elif slotData.condition <= 50 && slotData.condition > 25:
        conditionValue.add_theme_color_override("font_color", Color.YELLOW)
    else:
        conditionValue.add_theme_color_override("font_color", Color.GREEN)

func HoverInfo(header: String, subheader: String, description: String):
    type.show()
    separator.show()
    info.show()

    title.text = header
    type.text = subheader
    info.text = description

    panel.size = Vector2(0, 0)
    interface.tooltipOffset = panel.size.y
