extends Node3D


var gameData = preload("res://Resources/GameData.tres")


@export var isActive = true


enum Zone{Area05, BorderZone, Vostok}
@export var zone = Zone.Area05


enum Frequency{Low, Medium, High, Constant}
@export var spawnFrequency = Frequency.Medium
@export var minimumDistance = 50
@export var spawnPool = 10
@export var spawnLimit = 3

@export_group("Initial Agents")
@export var initialGuard = false
@export var initialHider = false
@export var initialGroup = false
@export var guardChange = 0
@export var hiderChange = 0
@export var groupChange = 0

@export_group("Map Rules")
@export var noHiding = false
@export var noEvade = false

@export_group("Debug")
@export var sensorBlocked = false
@export var fireBlocked = false
@export var damageBlocked = false
@export var forcePistol = false
@export var forceRifle = false
@export var forceHeadlamps = false
@export var forceCombat = false
@export var forceDefend = false
@export var forceHunt = false
@export var forceAttack = false
@export var allowIK = false
@export var noVelocity = false
@export var inversePoles = false
@export var noSensorDelay = false
@export var noAnimationDelay = false
@export var infiniteHealth = false
@export var showGizmos = false


var bandit = preload("res://AI/Bandit/AI_Bandit.tscn")
var guard = preload("res://AI/Guard/AI_Guard.tscn")
var military = preload("res://AI/Military/AI_Military.tscn")
var activeAgents = 0
var agent


var spawnTime = 1.0
var spawnTimer = 0.0


@onready var pool = $Pool
@onready var spawns = $Spawns
@onready var waypoints = $Waypoints
@onready var patrols = $Patrols
@onready var covers = $Covers
@onready var hides = $Hides
@onready var groups = $Groups
@onready var agents = $Agents


var groupAlerted = false

func _ready():
    if !showGizmos:
        HideGizmos()


    if !isActive || gameData.flycam:
        return


    if zone == Zone.Area05:
        agent = bandit
    elif zone == Zone.BorderZone:
        agent = guard
    elif zone == Zone.Vostok:
        agent = military


    CreatePool()


    if initialGuard:
        var guardRoll = randi_range(0, 100)
        if guardRoll < guardChange:
            SpawnGuard()


    if initialHider:
        var hiderRoll = randi_range(0, 100)
        if hiderRoll < hiderChange:
            SpawnHider()


    if initialGroup:
        var groupRoll = randi_range(0, 100)
        if groupRoll < groupChange:
            SpawnGroup()

func _physics_process(delta):
    if !isActive:
        return

    spawnTime -= delta

    if spawnTime <= 0:


        if activeAgents < spawnLimit:

            SpawnWanderer()
        else:
            print("Spawn blocked: Agent limit reached")


        if spawnFrequency == Frequency.Low:
            spawnTime = randf_range(60, 120)
        elif spawnFrequency == Frequency.Medium:
            spawnTime = randf_range(10, 120)
        elif spawnFrequency == Frequency.High:
            spawnTime = randf_range(1, 10)
        elif spawnFrequency == Frequency.Constant:
            spawnTime = 1

func CreatePool():
    pool.global_position = Vector3(0, 1000, 0)

    for amount in spawnPool:

        var newAgent = agent.instantiate()
        pool.add_child(newAgent)

        newAgent.waypoints = waypoints
        newAgent.patrols = patrols
        newAgent.covers = covers
        newAgent.hides = hides

        newAgent.global_position = pool.global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
        newAgent.Pause()

    print("POOL CREATED")

func SpawnGuard():
    if pool.get_child_count() == 0:
        print("Spawn blocked (Guard): Pool ended")
        return

    var patrolPoint = patrols.get_child(randi_range(0, patrols.get_child_count() - 1))


    var newAgent = pool.get_child(0)
    newAgent.reparent(agents)

    newAgent.waypoints = waypoints
    newAgent.patrols = patrols
    newAgent.covers = covers
    newAgent.hides = hides
    newAgent.currentPoint = patrolPoint
    newAgent.currentArea = patrolPoint.area

    newAgent.global_transform = patrolPoint.global_transform
    newAgent.ActivateGuard()

    activeAgents += 1
    print("GUARD SPAWNED")

func SpawnHider():
    if pool.get_child_count() == 0:
        print("Spawn blocked (Hider): Pool ended")
        return

    var hidePoint = hides.get_child(randi_range(0, hides.get_child_count() - 1))


    var newAgent = pool.get_child(0)
    newAgent.reparent(agents)

    newAgent.waypoints = waypoints
    newAgent.patrols = patrols
    newAgent.covers = covers
    newAgent.hides = hides
    newAgent.currentPoint = hidePoint

    newAgent.global_transform = hidePoint.global_transform
    newAgent.ActivateHider()

    activeAgents += 1
    print("HIDER SPAWNED")

func SpawnGroup():
    var groupArea = groups.get_child(randi_range(0, groups.get_child_count() - 1))

    for groupPoint in groupArea.get_children():

        if pool.get_child_count() == 0:
            print("Spawn blocked (Group): Pool ended")
            return


        var newAgent = pool.get_child(0)
        newAgent.reparent(agents)

        newAgent.waypoints = waypoints
        newAgent.patrols = patrols
        newAgent.covers = covers
        newAgent.hides = hides
        newAgent.groups = groups
        newAgent.currentPoint = groupPoint

        newAgent.global_transform = groupPoint.global_transform
        newAgent.ActivateGroup()

        activeAgents += 1
        print("GROUP SPAWNED")

func SpawnWanderer():
    if pool.get_child_count() == 0:
        print("Spawn blocked (Wanderer): Pool ended")
        return

    var availablePoints: Array[Node3D]
    var available = false


    for spawnPoint in spawns.get_children():

        var distanceToPlayer = spawnPoint.global_transform.origin.distance_to(gameData.playerPosition)


        if distanceToPlayer > minimumDistance:

            availablePoints.append(spawnPoint)
            available = true


    if available:

        var randomIndex = randi_range(0, availablePoints.size() - 1)
        var spawnPoint = availablePoints[randomIndex]


        var newAgent = pool.get_child(0)
        newAgent.reparent(agents)

        newAgent.waypoints = waypoints
        newAgent.patrols = patrols
        newAgent.covers = covers
        newAgent.hides = hides
        newAgent.currentPoint = spawnPoint

        newAgent.global_transform = spawnPoint.global_transform
        newAgent.ActivateWanderer()

        activeAgents += 1
        print("WANDERER SPAWNED")


    else:
        print("Wanderer: No available spawn points")

func AlertGroup():
    if !groupAlerted:
        groupAlerted = true
        print("Group Alerted")

        for child in agents.get_children():
            if child.currentState == child.State.Group:
                await get_tree().create_timer(randi_range(0, 2)).timeout;
                child.lastKnownLocation = gameData.playerPosition
                child.Decision()

func DestroyAllAI():
    activeAgents = 0
    var childCount = agents.get_child_count()

    if childCount != 0:
        for n in agents.get_children():
            remove_child(n)
            n.queue_free()

func HideGizmos():
    if spawns:
        spawns.hide()
    if waypoints:
        waypoints.hide()
    if patrols:
        patrols.hide()
    if groups:
        groups.hide()
    if covers:
        covers.hide()
    if hides:
        hides.hide()
