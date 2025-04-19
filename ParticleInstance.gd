extends Node3D

var particle: GPUParticles3D;
@export var lifeTime = 1.0
@export var flashTime = 0.1
@export var flashRange = 1.0
@export var flashEnergy = 1.0
@export var flash: OmniLight3D

func Emit():
    particle = get_child(0)
    particle.one_shot = true
    particle.emitting = true;

    await get_tree().create_timer(lifeTime).timeout;
    queue_free();

func Flash():
    if flash:
        flash.omni_range = flashRange
        flash.light_energy = flashEnergy

        await get_tree().create_timer(flashTime).timeout;
        flash.omni_range = 0.0

func Cache():
    particle = get_child(0)
    particle.one_shot = false
    particle.emitting = true;
