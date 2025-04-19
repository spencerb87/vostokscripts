extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var impact = $Impact
@onready var damage = $Damage
@onready var health = $Health
@onready var submerged = $Submerged


var healthMaterial = preload("res://UI/Effects/MT_Health.tres")
var healthOpacity = 0.0


var impactMaterial = preload("res://UI/Effects/MT_Impact.tres")
var impactOpacity = 0.0


var damageMaterial = preload("res://UI/Effects/MT_Damage.tres")
var damageOpacity = 0.0


var submergedMaterial = preload("res://UI/Effects/MT_Submerged.tres")

func _ready():
    impactMaterial.set_shader_parameter("opacity", 0.0)
    damageMaterial.set_shader_parameter("opacity", 0.0)
    healthMaterial.set_shader_parameter("opacity", 0.0)
    impact.hide()
    damage.hide()
    health.hide()
    submerged.hide()

func _physics_process(delta):
    if Engine.get_physics_frames() % 2 == 0 && !gameData.flycam:
        ImpactEffect(delta)
        DamageEffect(delta)
        HealthEffect(delta)
        SubmergedEffect()

func ImpactEffect(delta):
    if gameData.impact:
        impactOpacity = lerp(impactOpacity, 10.0, delta * 2)
        impactMaterial.set_shader_parameter("opacity", impactOpacity)
    else:
        impactOpacity = lerp(impactOpacity, 0.0, delta * 2)
        impactMaterial.set_shader_parameter("opacity", impactOpacity)

    if impactOpacity > 5.0:
        gameData.impact = false


    if impactOpacity > 0.01:
        impact.show()
    else:
        impact.hide()

func DamageEffect(delta):
    if gameData.damage:
        damageOpacity = lerp(damageOpacity, 1.0, delta * 2)
        damageMaterial.set_shader_parameter("opacity", damageOpacity)
    else:
        damageOpacity = lerp(damageOpacity, 0.0, delta * 2)
        damageMaterial.set_shader_parameter("opacity", damageOpacity)

    if damageOpacity > 0.5:
        gameData.damage = false


    if damageOpacity > 0.01:
        damage.show()
    else:
        damage.hide()

func HealthEffect(delta):
    if gameData.health < 50:
        var healthInversion = inverse_lerp(100, 0, gameData.health)
        healthOpacity = lerp(healthOpacity, healthInversion, delta)
        healthMaterial.set_shader_parameter("opacity", healthOpacity)
    else:
        healthOpacity = lerp(healthOpacity, 0.0, delta)
        healthMaterial.set_shader_parameter("opacity", healthOpacity)


    if healthOpacity > 0.01:
        health.show()
    else:
        health.hide()

func SubmergedEffect():
    if gameData.isSubmerged:
        submerged.show()

        if gameData.TOD == 1:
            submergedMaterial.set_shader_parameter("color", Color8(20, 30, 40))
        elif gameData.TOD == 2:
            submergedMaterial.set_shader_parameter("color", Color8(20, 50, 60))
        elif gameData.TOD == 3:
            submergedMaterial.set_shader_parameter("color", Color8(25, 30, 25))
        elif gameData.TOD == 4:
            submergedMaterial.set_shader_parameter("color", Color8(1, 5, 5))
    else:
        submerged.hide()
