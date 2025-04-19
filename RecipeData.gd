extends Resource
class_name RecipeData

@export var name: String
@export var locked: bool
@export var workbench: bool
@export var tester: bool
@export var heat: bool
@export var time: float
@export var requires: Array[ItemData]
@export var results: Array[ItemData]
