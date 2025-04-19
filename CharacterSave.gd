extends Resource
class_name CharacterSave


@export var health: float
@export var energy: float
@export var hydration: float
@export var temperature: float


@export var bodyStamina: float
@export var armStamina: float


@export var overweight: bool
@export var starvation: bool
@export var dehydration: bool
@export var bleeding: bool
@export var fracture: bool
@export var burn: bool
@export var rupture: bool
@export var headshot: bool


@export var inventory: Array[SlotData] = []


@export var equipment: Array[SlotData] = []


@export var primary: bool
@export var secondary: bool
@export var knife: bool
@export var weaponPosition: int
@export var flashlight: bool
@export var NVG: bool
