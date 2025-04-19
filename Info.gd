extends Control

@export var header: String
@export var subheader: String
@export_multiline var description: String

var interface

func _ready():
    interface = owner

func _on_mouse_entered():
    if !interface.grabber.visible:
        interface.tooltip.HoverInfo(header, subheader, description)


        if interface.tooltipMode == 1:
            interface.hovering = true

func _on_mouse_exited():
    if !interface.grabber.visible:
        interface.tooltip.Reset()


        if interface.tooltipMode == 1:
            interface.tooltip.hide()
            interface.tooltipTimer = 0.0
            interface.hovering = false
