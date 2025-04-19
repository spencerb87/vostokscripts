extends Resource
class_name AudioLibrary

@export_group("Ambient")
@export var ambientDay: AudioEvent
@export var ambientDawn: AudioEvent
@export var ambientDusk: AudioEvent
@export var ambientNight: AudioEvent

@export_group("Weather")
@export var windLight: AudioEvent
@export var windMedium: AudioEvent
@export var windHeavy: AudioEvent
@export var windHowl: AudioEvent
@export var rainLight: AudioEvent
@export var rainHeavy: AudioEvent
@export var thunderHum: AudioEvent
@export var thunderStrike: AudioEvent

@export_group("Character")
@export var damage: AudioEvent
@export var impact: AudioEvent
@export var armor: AudioEvent
@export var armorBreak: AudioEvent
@export var death: AudioEvent

@export_group("Medical")
@export var indicator: AudioEvent
@export var overweight: AudioEvent
@export var starvation: AudioEvent
@export var dehydration: AudioEvent
@export var bleeding: AudioEvent
@export var fracture: AudioEvent
@export var burn: AudioEvent
@export var rupture: AudioEvent

@export_group("Doors")
@export var doorWood: AudioEvent
@export var doorMetal: AudioEvent

@export_group("Interaction")
@export var pickup: AudioEvent
@export var equip: AudioEvent
@export var unequip: AudioEvent
@export var transition: AudioEvent
@export var flashlight: AudioEvent
@export var radio: AudioEvent
@export var firemode: AudioEvent
@export var ignite: AudioEvent
@export var extinguish: AudioEvent
@export var container: AudioEvent
@export var revive: AudioEvent

@export_group("UI")
@export var UIClick: AudioEvent
@export var UIEquip: AudioEvent
@export var UIUnequip: AudioEvent
@export var UIDrop: AudioEvent
@export var UIAttach: AudioEvent
@export var UIArmor: AudioEvent
@export var UIError: AudioEvent
@export var UICraftStart: AudioEvent
@export var UICraftEnd: AudioEvent
@export var UICraftMetal: AudioEvent
@export var UITraderOpen: AudioEvent
@export var UITraderClose: AudioEvent
@export var UITraderTrade: AudioEvent
@export var UITraderReset: AudioEvent
@export var UITraderTask: AudioEvent

@export_group("Vostok")
@export var vostokEnter: AudioEvent

@export_group("Hit")
@export var hitGrass: AudioEvent
@export var hitDirt: AudioEvent
@export var hitAsphalt: AudioEvent
@export var hitRock: AudioEvent
@export var hitWood: AudioEvent
@export var hitMetal: AudioEvent
@export var hitConcrete: AudioEvent
@export var hitTarget: AudioEvent
@export var hitWater: AudioEvent
@export var hitSnowSoft: AudioEvent
@export var hitSnowHard: AudioEvent

@export_group("Actions")
@export var unload: AudioEvent
@export var unloadEnd: AudioEvent

@export_group("Footstep")
@export var footstepGrass: AudioEvent
@export var footstepGrassLand: AudioEvent
@export var footstepDirt: AudioEvent
@export var footstepDirtLand: AudioEvent
@export var footstepAsphalt: AudioEvent
@export var footstepAsphaltLand: AudioEvent
@export var footstepRock: AudioEvent
@export var footstepRockLand: AudioEvent
@export var footstepWood: AudioEvent
@export var footstepWoodLand: AudioEvent
@export var footstepMetal: AudioEvent
@export var footstepMetalLand: AudioEvent
@export var footstepConcrete: AudioEvent
@export var footstepConcreteLand: AudioEvent
@export var footstepSnowSoft: AudioEvent
@export var footstepSnowSoftLand: AudioEvent
@export var footstepSnowHard: AudioEvent
@export var footstepSnowHardLand: AudioEvent
@export var footstepWater: AudioEvent
@export var footstepWaterLand: AudioEvent

@export_group("Movement")
@export var movementCloth: AudioEvent
@export var movementGear: AudioEvent

@export_group("Water")
@export var waterGasp: AudioEvent
@export var waterDive: AudioEvent
@export var waterSurface: AudioEvent
@export var swimSurface: AudioEvent
@export var swimSubmerged: AudioEvent

@export_group("Flyby")
@export var supersonic: AudioEvent
@export var crackLight: AudioEvent
@export var crackMedium: AudioEvent
@export var crackHeavy: AudioEvent

@export_group("Casings")
@export var casingDropSoft: AudioEvent
@export var casingDropHard: AudioEvent
@export var casingDropWood: AudioEvent
@export var shellDropHard: AudioEvent
@export var shellDropSoft: AudioEvent

@export_group("Knives")
@export var knifeDraw: AudioEvent
@export var knifeHolster: AudioEvent
@export var knifeSlash: AudioEvent
@export var knifeStab: AudioEvent
@export var knifeThrowStart: AudioEvent
@export var knifeThrowEnd: AudioEvent
@export var knifeInspectStart: AudioEvent
@export var knifeInspectEnd: AudioEvent
@export var knifeInspectTurn: AudioEvent
@export var knifeBounceSoil: AudioEvent
@export var knifeBounceWood: AudioEvent
@export var knifeBounceMetal: AudioEvent
@export var knifeStickSoil: AudioEvent
@export var knifeStickWood: AudioEvent
@export var knifeStickFlesh: AudioEvent
@export var knifeHitSoft: AudioEvent
@export var knifeHitWood: AudioEvent
@export var knifeHitHard: AudioEvent
@export var knifeHitMetal: AudioEvent
@export var knifeHitFleshSlash: AudioEvent
@export var knifeHitFleshStab: AudioEvent
