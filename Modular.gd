@tool
extends MeshInstance3D


const M_Roof_Corrugated = preload("res://Common/Modular/MT_M_Roof_Corrugated.tres")
const M_Insulation = preload("res://Common/Modular/MT_M_Insulation.tres")

const M_Siding_White = preload("res://Common/Modular/MT_M_Wood_Siding_White.tres")
const M_Siding_Yellow = preload("res://Common/Modular/MT_M_Wood_Siding_Yellow.tres")
const M_Siding_Red = preload("res://Common/Modular/MT_M_Wood_Siding_Red.tres")
const M_Siding_Green = preload("res://Common/Modular/MT_M_Wood_Siding_Green.tres")
const MT_Bricks_Red = preload("res://Common/Modular/MT_M_Bricks_Red.tres")
const MT_Bricks_White = preload("res://Common/Modular/MT_M_Bricks_White.tres")

const M_Ceiling_Plaster = preload("res://Common/Modular/MT_M_Ceiling_Plaster.tres")
const M_Wallpaper_Generic = preload("res://Common/Modular/MT_M_Wallpaper_Generic.tres")
const M_Wallpaper_Retro = preload("res://Common/Modular/MT_M_Wallpaper_Retro.tres")
const M_Wallpaper_Fabric = preload("res://Common/Modular/MT_M_Wallpaper_Fabric.tres")
const M_Floor_Chipboard = preload("res://Common/Modular/MT_M_Floor_Chipboard.tres")

const M_Wood_Planks_NS = preload("res://Common/Modular/MT_M_Wood_Planks_NS.tres")

const M_Ceiling_Concrete = preload("res://Common/Modular/MT_M_Ceiling_Concrete.tres")
const M_Bricks_White_NS = preload("res://Common/Modular/MT_M_Bricks_White_NS.tres")
const M_Floor_Concrete = preload("res://Common/Modular/MT_M_Floor_Concrete.tres")


const M_Concrete_Base = preload("res://Common/Modular/MT_M_Concrete_Base.tres")
const M_Metal_Generic = preload("res://Common/Modular/MT_M_Metal_Generic.tres")


const surface = preload("res://Scripts/Surface.gd")


const probe = preload("res://Resources/Probe.tscn")

@export var reset: bool = false:
    set = ExecuteReset

@export_group("Roof")
@export var roofCorrugated: bool = false:
    set = ExecuteRoofCorrugated
@export var insulation: bool = false:
    set = ExecuteInsulation

@export_group("Exteriors")
@export var sidingWhite: bool = false:
    set = ExecuteSidingWhite
@export var sidingYellow: bool = false:
    set = ExecuteSidingYellow
@export var sidingRed: bool = false:
    set = ExecuteSidingRed
@export var sidingGreen: bool = false:
    set = ExecuteSidingGreen
@export var bricksRed: bool = false:
    set = ExecuteBricksRed
@export var bricksWhite: bool = false:
    set = ExecuteBricksWhite

@export_group("Rooms")
@export var roomGeneric: bool = false:
    set = ExecuteRoomGeneric
@export var roomRetro: bool = false:
    set = ExecuteRoomRetro
@export var roomGarage: bool = false:
    set = ExecuteRoomGarage
@export var roomShed: bool = false:
    set = ExecuteRoomShed

@export_group("Bases")
@export var baseConcrete: bool = false:
    set = ExecuteBaseConcrete

@export_group("Colliders")
@export var wood: bool = false:
    set = ExecuteWoodCollider
@export var metal: bool = false:
    set = ExecuteMetalCollider
@export var concrete: bool = false:
    set = ExecuteConcreteCollider

@export_group("Probes")
@export var placeProbe: bool = false:
    set = ExecutePlaceProbe



func ExecuteReset(_value: bool) -> void :
    var materialCount = get_surface_override_material_count()

    if materialCount == 1:
        set_surface_override_material(0, null)
    elif materialCount == 2:
        set_surface_override_material(0, null)
        set_surface_override_material(1, null)
    elif materialCount == 3:
        set_surface_override_material(0, null)
        set_surface_override_material(1, null)
        set_surface_override_material(2, null)

    for child in get_children():
        if child is StaticBody3D:
            remove_child(child)
            child.queue_free()

    reset = false



func ExecuteRoofCorrugated(_value: bool) -> void :
    set_surface_override_material(0, M_Roof_Corrugated)
    set_surface_override_material(1, M_Metal_Generic)
    roofCorrugated = false

func ExecuteInsulation(_value: bool) -> void :
    set_surface_override_material(0, M_Insulation)
    insulation = false



func ExecuteSidingWhite(_value: bool) -> void :
    set_surface_override_material(0, M_Siding_White)
    sidingWhite = false

func ExecuteSidingYellow(_value: bool) -> void :
    set_surface_override_material(0, M_Siding_Yellow)
    sidingYellow = false

func ExecuteSidingRed(_value: bool) -> void :
    set_surface_override_material(0, M_Siding_Red)
    sidingRed = false

func ExecuteSidingGreen(_value: bool) -> void :
    set_surface_override_material(0, M_Siding_Green)
    sidingGreen = false

func ExecuteBricksRed(_value: bool) -> void :
    set_surface_override_material(0, MT_Bricks_Red)
    bricksRed = false

func ExecuteBricksWhite(_value: bool) -> void :
    set_surface_override_material(0, MT_Bricks_White)
    bricksWhite = false



func ExecuteRoomGeneric(_value: bool) -> void :
    set_surface_override_material(0, M_Ceiling_Plaster)
    set_surface_override_material(1, M_Wallpaper_Generic)
    set_surface_override_material(2, M_Floor_Chipboard)
    roomGeneric = false

func ExecuteRoomRetro(_value: bool) -> void :
    set_surface_override_material(0, M_Ceiling_Plaster)
    set_surface_override_material(1, M_Wallpaper_Retro)
    set_surface_override_material(2, M_Floor_Chipboard)
    roomRetro = false

func ExecuteRoomShed(_value: bool) -> void :
    var materialCount = get_surface_override_material_count()

    if materialCount == 3:
        set_surface_override_material(0, M_Wood_Planks_NS)
        set_surface_override_material(1, M_Wood_Planks_NS)
        set_surface_override_material(2, M_Floor_Chipboard)
    else:
        set_surface_override_material(0, M_Wood_Planks_NS)
        set_surface_override_material(1, M_Floor_Chipboard)

    roomShed = false

func ExecuteRoomGarage(_value: bool) -> void :
    set_surface_override_material(0, M_Ceiling_Concrete)
    set_surface_override_material(1, M_Bricks_White_NS)
    set_surface_override_material(2, M_Floor_Concrete)
    roomGarage = false



func ExecuteBaseConcrete(_value: bool) -> void :
    set_surface_override_material(0, M_Concrete_Base)
    baseConcrete = false



func ExecuteWoodCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 5
    wood = false

func ExecuteMetalCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 6
    metal = false

func ExecuteConcreteCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 7
    concrete = false



func ExecutePlaceProbe(_value: bool) -> void :
    var probeInstance: ReflectionProbe = probe.instantiate()

    add_child(probeInstance, true)
    probeInstance.set_owner(get_tree().edited_scene_root);
    probeInstance.name = "Probe_" + name

    probeInstance.position = get_aabb().get_center()
    probeInstance.size = get_aabb().size

    probeInstance.size.x += 0.1
    probeInstance.size.y += 0.1
    probeInstance.size.z += 0.1

    placeProbe = false
