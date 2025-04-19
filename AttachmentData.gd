extends ItemData
class_name AttachmentData

@export_group("Category")
enum Category{Muzzle, Optic}
@export var category = Category.Muzzle

@export_group("Optic Parameters")
@export var scope = false
@export var variable = false
@export var secondary = false
@export var hasMount = false
@export var ocularOpacity = 1.0
@export var reticleSize = 0.1
@export var shadowSize = 0.1
@export var variableReticle: Vector3
