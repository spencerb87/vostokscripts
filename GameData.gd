extends Resource
class_name GameData


var zone: String
var currentMap: String
var previousMap: String
var menu: bool
var shelter: bool
var tutorial: bool
var permadeath = false
var flycam = false


var season = 1
var TOD = 2
var weather = 1
var aurora = false
var indoor = false


var settings = false
var interface = false
var weaponUI = false


var health = 100.0
var energy = 100.0
var hydration = 100.0
var temperature = 100.0
var oxygen = 100.0


var bodyStamina = 100.0
var armStamina = 100.0


var starvation = false
var dehydration = false
var overweight = false
var bleeding = false
var fracture = false
var burn = false
var rupture = false
var headshot = false


var inputDirection = Vector2.ZERO
var playerPosition = Vector3.ZERO
var playerVector = Vector3.ZERO


var baseFOV = 70.0
var aimFOV = 70.0
var isScoped = false
var headbob = 1.0


var lookSensitivity = 1.0
var aimSensitivity = 1.0
var scopeSensitivity = 1.0


var mouseMode = 1
var sprintMode = 1
var leanMode = 1
var aimMode = 1


var freeze = false
var isDead = false
var isGrounded = false
var isFalling = false
var isFlying = false
var isWater = false
var isSwimming = false
var isSubmerged = false
var isIdle = false
var isMoving = false
var isWalking = false
var isRunning = false
var isCrouching = false
var isAiming = false
var isCanted = false
var isFiring = false
var isColliding = false
var isReloading = false
var isInspecting = false
var isPreparing = false
var isInserting = false
var isDrawing = false
var isCaching = false
var isDragging = false
var isBurning = false
var isOccupied = false
var isCrafting = false
var isTrading = false
var isTransitioning = false
var isPlacing = false


var surface = 0
var jump = false
var land = false
var crouch = false
var stand = false
var damage = false
var impact = false


var leanLBlocked = false
var leanRBlocked = false


var primary = false
var secondary = false
var knife = false
var weaponType = 0
var weaponPosition = 1
var inspectPosition = 1
var firemode = 1
var ammo = 0


var flashlight = false
var NVG = false


var interaction = false
var interactionText: String
var message = false
var messageText: String


var heat = false


var toggleDelay = false


var musicPreset = 1


var tooltip = null


func Reset():
    RenderingServer.global_shader_parameter_set("Storm", false)
    RenderingServer.global_shader_parameter_set("Winter", false)

    zone = "Area 05"
    currentMap = "Attic"
    previousMap = "Village"
    menu = false
    shelter = false
    tutorial = false

    health = 100.0
    energy = 100.0
    hydration = 100.0
    temperature = 100.0
    oxygen = 100.0

    bodyStamina = 100.0
    armStamina = 100.0

    starvation = false
    dehydration = false
    overweight = false
    bleeding = false
    fracture = false
    burn = false
    rupture = false
    headshot = false

    inputDirection = Vector2.ZERO
    playerPosition = Vector3.ZERO
    playerVector = Vector3.ZERO

    isDead = false
    isGrounded = false
    isFalling = false
    isFlying = false
    isWater = false
    isSwimming = false
    isSubmerged = false
    isIdle = false
    isMoving = false
    isWalking = false
    isRunning = false
    isCrouching = false
    isAiming = false
    isCanted = false
    isFiring = false
    isColliding = false
    isReloading = false
    isInspecting = false
    isPreparing = false
    isInserting = false
    isDrawing = false
    isCaching = false
    isDragging = false
    isOccupied = false
    isCrafting = false
    isTrading = false
    isTransitioning = false
    primary = false
    secondary = false
    knife = false
    weaponType = 0
    weaponPosition = 1
    firemode = 1

    season = 1
    weather = 1
    aurora = false
    TOD = 2
    ammo = 0
    flashlight = false
    NVG = false
    freeze = false
    settings = false
    interface = false
    surface = 0
    isPlacing = false


    interaction = false
    interactionText = ""
    message = false
    messageText = ""

    tooltip = null

    inspectPosition = 1
    weaponUI = false
    indoor = false
    permadeath = false

    baseFOV = 70.0
    aimFOV = 70.0
    isScoped = false
    headbob = 1.0

    lookSensitivity = 1.0
    aimSensitivity = 1.0
    scopeSensitivity = 1.0

    mouseMode = 1
    sprintMode = 1
    leanMode = 1
    aimMode = 1

    jump = false
    land = false
    crouch = false
    stand = false
    damage = false
    impact = false

    leanLBlocked = false
    leanRBlocked = false

    toggleDelay = false

    musicPreset = 1

    heat = false
