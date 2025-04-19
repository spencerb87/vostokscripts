@tool
extends Node3D

@export var generate: bool = false:
    set = ExecuteGenerate
@export var clear: bool = false:
    set = ExecuteClear

@export_group("Elements")
@export var elements: Array[PackedScene]

@export_group("Parameters")
@export var start = 0
@export var width = 0
@export var density = 0
@export var removal = 0
@export var offset = 0.0
@export var YOffset = 0.0
@export var minScale = 1.0
@export var maxScale = 1.0
@export var XRotation = 0.0
@export var YRotation = 0.0
@export var ZRotation = 0.0
@export var surfaceNormal = false

@export_group("Masking")
@export_flags_3d_physics var layers
@export var surface = 0
@export var perimeter = 0
@export var maxHeight = 0
@export var minHeight = 0

var hitPosition
var hitNormal

func ExecuteGenerate(_value: bool) -> void :
    ExecuteClear(true)


    for x in range(-200, 200):
        for y in range(start, start + width):
            if density != 0 && (x % density == 0 and y % density == 0):

                var spawnPosition = Vector3(x, 0, y)
                var randomRotation = Vector3(randf_range( - XRotation, XRotation), randf_range( - YRotation, YRotation), randf_range( - ZRotation, ZRotation))
                var randomScale = randf_range(minScale, maxScale)


                if !RaycastCheck(spawnPosition + Vector3(0, maxHeight, 0), spawnPosition + Vector3(0, minHeight, 0), true):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(0, 100, - perimeter), spawnPosition + Vector3(0, -200, - perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, - perimeter), spawnPosition + Vector3(perimeter, -200, - perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, 0), spawnPosition + Vector3(perimeter, -200, 0), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, perimeter), spawnPosition + Vector3(perimeter, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(0, 100, perimeter), spawnPosition + Vector3(0, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, perimeter), spawnPosition + Vector3( - perimeter, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, 0), spawnPosition + Vector3( - perimeter, -200, 0), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, - perimeter), spawnPosition + Vector3( - perimeter, -200, - perimeter), false):
                    continue


                var randomIndex = randi_range(0, elements.size() - 1)
                var element = elements[randomIndex].instantiate()


                add_child(element, true)
                element.set_owner(get_tree().edited_scene_root);


                element.scale = Vector3(randomScale, randomScale, randomScale)
                element.position = hitPosition + Vector3(0, YOffset * randomScale, 0)


                element.rotation_degrees = randomRotation


                if surfaceNormal:
                    element.global_transform.basis = SurfaceNormal(element.global_transform.basis, hitNormal)


    if get_child_count() != 0:
        for remove in removal:
            var randomIndex = randi_range(0, get_child_count() - 1)
            var randomChild = get_child(randomIndex)
            remove_child(randomChild)
            randomChild.queue_free()

    generate = false

func RaycastCheck(rayStart: Vector3, rayEnd: Vector3, originRay: bool) -> bool:
    var ray = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, layers)
    var hit = get_world_3d().direct_space_state.intersect_ray(ray)

    if !hit.is_empty() && hit.collider.get("surfaceType") == surface:
        if originRay:
            hitPosition = hit.position
            hitNormal = hit.normal

        return true
    else:
        return false

func SurfaceNormal(node_basis, normal):
    var result = Basis()
    var newScale = node_basis.get_scale().abs()
    result.x = normal.cross(node_basis.z)
    result.y = normal
    result.z = node_basis.x.cross(normal)

    result = result.orthonormalized()
    result.x *= newScale.x
    result.y *= newScale.y
    result.z *= newScale.z
    return result

func ExecuteClear(_value: bool) -> void :
    var childCount = get_child_count()

    if childCount != 0:
        for child in get_children():
            remove_child(child)
            child.queue_free()

    clear = false
