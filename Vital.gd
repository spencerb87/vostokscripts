extends Control


var gameData = preload("res://Resources/GameData.tres")


enum Type{Health, Energy, Hydration, Temperature, Body, Arm, Oxygen}
@export var type = Type.Health
@export var progression = false
@export var progressBar: ProgressBar
@export var percentage: Label
@export var state: Label

func _physics_process(_delta):
    if Engine.get_physics_frames() % 10 == 0:



        if type == Type.Health:

            percentage.text = str(snapped(gameData.health, 1.0))

            if gameData.health <= 25:
                percentage.add_theme_color_override("font_color", Color.RED)
            elif gameData.health > 25 && gameData.health <= 50:
                percentage.add_theme_color_override("font_color", Color.YELLOW)
            else:
                percentage.add_theme_color_override("font_color", Color.GREEN)

            if progression:
                progressBar.value = gameData.health

                if gameData.health <= 25:
                    progressBar.modulate = Color8(255, 0, 0, 128)
                elif gameData.health > 25 && gameData.health <= 50:
                    progressBar.modulate = Color8(255, 255, 0, 128)
                else:
                    progressBar.modulate = Color8(0, 255, 0, 128)



        elif type == Type.Energy:

            percentage.text = str(snapped(gameData.energy, 1.0))

            if gameData.energy <= 25:
                percentage.add_theme_color_override("font_color", Color.RED)
            elif gameData.energy > 25 && gameData.energy <= 50:
                percentage.add_theme_color_override("font_color", Color.YELLOW)
            else:
                percentage.add_theme_color_override("font_color", Color.GREEN)

            if progression:
                progressBar.value = gameData.energy

                if gameData.energy <= 25:
                    progressBar.modulate = Color8(255, 0, 0, 128)
                elif gameData.energy > 25 && gameData.energy <= 50:
                    progressBar.modulate = Color8(255, 255, 0, 128)
                else:
                    progressBar.modulate = Color8(0, 255, 0, 128)



        elif type == Type.Hydration:

            percentage.text = str(snapped(gameData.hydration, 1.0))

            if gameData.hydration <= 25:
                percentage.add_theme_color_override("font_color", Color.RED)
            elif gameData.hydration > 25 && gameData.hydration <= 50:
                percentage.add_theme_color_override("font_color", Color.YELLOW)
            else:
                percentage.add_theme_color_override("font_color", Color.GREEN)

            if progression:
                progressBar.value = gameData.hydration

                if gameData.hydration <= 25:
                    progressBar.modulate = Color8(255, 0, 0, 128)
                elif gameData.hydration > 25 && gameData.hydration <= 50:
                    progressBar.modulate = Color8(255, 255, 0, 128)
                else:
                    progressBar.modulate = Color8(0, 255, 0, 128)



        elif type == Type.Temperature:

            percentage.text = str(snapped(gameData.temperature, 1.0))

            if gameData.temperature <= 25:
                percentage.add_theme_color_override("font_color", Color.RED)
            elif gameData.temperature > 25 && gameData.temperature <= 50:
                percentage.add_theme_color_override("font_color", Color.YELLOW)
            else:
                percentage.add_theme_color_override("font_color", Color.GREEN)

            if progression:
                progressBar.value = gameData.temperature

                if gameData.temperature <= 25:
                    progressBar.modulate = Color8(255, 0, 0, 128)
                elif gameData.temperature > 25 && gameData.temperature <= 50:
                    progressBar.modulate = Color8(255, 255, 0, 128)
                else:
                    progressBar.modulate = Color8(0, 255, 0, 128)



        elif type == Type.Body:

            percentage.text = str(snapped(gameData.bodyStamina, 1.0))

            if progression:
                progressBar.value = clampi(gameData.bodyStamina, 0, 100)
                progressBar.modulate = Color8(255, 255, 255, 64)



        elif type == Type.Arm:

            percentage.text = str(snapped(gameData.armStamina, 1.0))

            if progression:
                progressBar.value = clampi(gameData.armStamina, 0, 100)
                progressBar.modulate = Color8(255, 255, 255, 64)




        elif type == Type.Oxygen:

            percentage.text = str(snapped(gameData.oxygen, 1.0))

            if progression:
                progressBar.value = clampi(gameData.oxygen, 0, 100)
                progressBar.modulate = Color8(0, 255, 255, 128)

            if gameData.isSwimming:
                state.text = "ON"
                state.modulate = Color8(0, 255, 0, 256)
            else:
                state.text = "OFF"
                state.modulate = Color8(255, 0, 0, 256)
