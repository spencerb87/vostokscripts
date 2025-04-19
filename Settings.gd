extends Control
class_name Settings


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var logo = $Logo


@onready var world


@export var hud: Control
@export var interface: Control
@export var audio: Node3D
@export var camera: Camera


@onready var masterBus = AudioServer.get_bus_index("Master")
@onready var ambientBus = AudioServer.get_bus_index("Ambient")
@onready var musicBus = AudioServer.get_bus_index("Music")


@onready var neutralText = $Settings / Buttons / Weather / Settings / Neutral
@onready var darkText = $Settings / Buttons / Weather / Settings / Dark
@onready var rainText = $Settings / Buttons / Weather / Settings / Rain
@onready var stormText = $Settings / Buttons / Weather / Settings / Storm


@onready var masterSlider = $Settings / Sliders / Audio / Settings / Master_Slider
@onready var ambientSlider = $Settings / Sliders / Audio / Settings / Ambient_Slider
@onready var musicSlider = $Settings / Sliders / Audio / Settings / Music_Slider
@onready var lookSlider = $Settings / Sliders / Mouse / Settings / Look_Slider
@onready var aimSlider = $Settings / Sliders / Mouse / Settings / Aim_Slider
@onready var scopeSlider = $Settings / Sliders / Mouse / Settings / Scope_Slider
@onready var FOVslider = $Settings / Sliders / Camera / Settings / FOV_Slider
@onready var headbobSlider = $Settings / Sliders / Camera / Settings / Headbob_Slider
@onready var exposureSlider = $Settings / Sliders / Color / Settings / Exposure_Slider
@onready var contrastSlider = $Settings / Sliders / Color / Settings / Contrast_Slider
@onready var saturationSlider = $Settings / Sliders / Color / Settings / Saturation_Slider
@onready var sharpnessSlider = $Settings / Sliders / Image / Settings / Sharpness_Slider
@onready var delaySlider = $Settings / Buttons / Tooltip / Settings / Delay_Slider


@onready var hover = $Settings / Buttons / Tooltip / Settings / Hover
@onready var toggle = $Settings / Buttons / Tooltip / Settings / Toggle
@onready var interpolateOff = $Settings / Sliders / Camera / Settings / Options / Interpolate_Off
@onready var interpolateOn = $Settings / Sliders / Camera / Settings / Options / Interpolate_On
@onready var musicOff = $Settings / Sliders / Music / Settings / Options / Music_Off
@onready var musicDynamic = $Settings / Sliders / Music / Settings / Options / Music_Dynamic
@onready var musicShelter = $Settings / Sliders / Music / Settings / Options / Music_Shelter
@onready var musicArea05 = $Settings / Sliders / Music / Settings / Options / Music_Area_05
@onready var musicBorder = $Settings / Sliders / Music / Settings / Options / Music_Border
@onready var musicVostok = $Settings / Sliders / Music / Settings / Options / Music_Vostok
@onready var summer = $Settings / Buttons / Season / Settings / Summer
@onready var winter = $Settings / Buttons / Season / Settings / Winter
@onready var dawn = $Settings / Buttons / Time / Settings / Dawn
@onready var day = $Settings / Buttons / Time / Settings / Day
@onready var dusk = $Settings / Buttons / Time / Settings / Dusk
@onready var night = $Settings / Buttons / Time / Settings / Night
@onready var neutral = $Settings / Buttons / Weather / Settings / Neutral
@onready var dark = $Settings / Buttons / Weather / Settings / Dark
@onready var rain = $Settings / Buttons / Weather / Settings / Rain
@onready var storm = $Settings / Buttons / Weather / Settings / Storm
@onready var simulate = $Settings / Buttons / Aurora / Settings / Simulate
@onready var fps_60 = $Settings / General / Frames / Settings / FPS_60
@onready var fps_120 = $Settings / General / Frames / Settings / FPS_120
@onready var fps_200 = $Settings / General / Frames / Settings / FPS_200
@onready var fps_300 = $Settings / General / Frames / Settings / FPS_300
@onready var vsync = $Settings / General / Frames / Settings / Vsync
@onready var unlimited = $Settings / General / Frames / Settings / Unlimited
@onready var RLow = $Settings / General / Rendering / Settings / R_Low
@onready var RMedium = $Settings / General / Rendering / Settings / R_Medium
@onready var RHigh = $Settings / General / Rendering / Settings / R_High
@onready var RUltra = $Settings / General / Rendering / Settings / R_Ultra
@onready var LLow = $Settings / General / Lighting / Settings / L_Low
@onready var LMedium = $Settings / General / Lighting / Settings / L_Medium
@onready var LHigh = $Settings / General / Lighting / Settings / L_High
@onready var LUltra = $Settings / General / Lighting / Settings / L_Ultra
@onready var MSAA_Off = $Settings / General / Antialiasing / Settings / MSAA_Off
@onready var MSAA_2x = $Settings / General / Antialiasing / Settings / MSAA_2x
@onready var MSAA_4x = $Settings / General / Antialiasing / Settings / MSAA_4x
@onready var MSAA_8x = $Settings / General / Antialiasing / Settings / MSAA_8x
@onready var nature_AA_Off = $Settings / General / Antialiasing / Settings / Nature_AA_Off
@onready var nature_AA_On = $Settings / General / Antialiasing / Settings / Nature_AA_On

@onready var map = $Settings / Buttons / HUD / Settings / Map
@onready var time = $Settings / Buttons / HUD / Settings / Time
@onready var fps = $Settings / Buttons / HUD / Settings / FPS
@onready var stats = $Settings / Buttons / HUD / Settings / Stats
@onready var menu = $Settings / General / General / Settings / Menu
@onready var quit = $Settings / General / General / Settings / Quit


@onready var fullscreen = $Settings / General / Display / Settings / Fullscreen
@onready var windowed = $Settings / General / Display / Settings / Windowed
@onready var monitors = $Settings / General / Display / Settings / Monitors
@onready var sizes = $Settings / General / Display / Settings / Sizes

var windowSizes: Dictionary = {
"Window: 100%": int(0), 
"Window: 90%": int(1), 
"Window: 75%": int(2), 
"Window: 50%": int(3)}

@onready var inputs = $Settings / Inputs
var preferences: Preferences
var currentRID: RID

func _ready():
    await get_tree().create_timer(0.1).timeout;

    currentRID = get_tree().get_root().get_viewport_rid()

    if !gameData.menu:
        logo.show()
        world = get_tree().current_scene.get_node("/root/Map/World")
        menu.disabled = false
        quit.disabled = false
    else:
        logo.hide()
        menu.disabled = true
        quit.disabled = true

    if gameData.flycam:
        return

    GetMonitors()
    GetWindowSizes()

    preferences = Preferences.Load()
    LoadPreferences()



func LoadPreferences():


    masterSlider.value = preferences.masterVolume
    AudioServer.set_bus_volume_db(masterBus, linear_to_db(preferences.masterVolume))
    AudioServer.set_bus_mute(masterBus, preferences.masterVolume < 0.1)

    ambientSlider.value = preferences.ambientVolume
    AudioServer.set_bus_volume_db(ambientBus, linear_to_db(preferences.ambientVolume))
    AudioServer.set_bus_mute(ambientBus, preferences.ambientVolume < 0.1)

    musicSlider.value = preferences.musicVolume
    AudioServer.set_bus_volume_db(musicBus, linear_to_db(preferences.musicVolume))
    AudioServer.set_bus_mute(musicBus, preferences.musicVolume < 0.1)



    if preferences.musicPreset == 1:
        musicOff.set_pressed_no_signal(true)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 2:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(true)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 3:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(true)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 4:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(true)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 5:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(true)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 6:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(true)
        musicVostok.set_pressed_no_signal(false)

    gameData.musicPreset = preferences.musicPreset

    if !gameData.menu:
        audio.UpdateMusic()



    if preferences.interpolate:
        interpolateOff.set_pressed_no_signal(false)
        interpolateOn.set_pressed_no_signal(true)
    else:
        interpolateOff.set_pressed_no_signal(true)
        interpolateOn.set_pressed_no_signal(false)

    if !gameData.menu:
        camera.interpolate = preferences.interpolate

    FOVslider.value = preferences.baseFOV
    gameData.baseFOV = preferences.baseFOV

    headbobSlider.value = preferences.headbob
    gameData.headbob = preferences.headbob



    lookSlider.value = preferences.lookSensitivity
    gameData.lookSensitivity = preferences.lookSensitivity

    aimSlider.value = preferences.aimSensitivity
    gameData.aimSensitivity = preferences.aimSensitivity

    scopeSlider.value = preferences.scopeSensitivity
    gameData.scopeSensitivity = preferences.scopeSensitivity



    exposureSlider.value = preferences.exposure
    if !gameData.menu:
        world.environment.environment.adjustment_brightness = preferences.exposure

    contrastSlider.value = preferences.contrast
    if !gameData.menu:
        world.environment.environment.adjustment_contrast = preferences.contrast

    saturationSlider.value = preferences.saturation
    if !gameData.menu:
        world.environment.environment.adjustment_saturation = preferences.saturation




    var remapValue = remap(preferences.sharpness, 0, 0.5, 0.5, 0)
    sharpnessSlider.value = remapValue

    if !gameData.menu:
        RenderingServer.viewport_set_fsr_sharpness(currentRID, preferences.sharpness)



    if preferences.tooltip == 1:
        hover.set_pressed_no_signal(true)
        toggle.set_pressed_no_signal(false)

        if !gameData.menu:
            interface.tooltipMode = 1

    elif preferences.tooltip == 2:
        hover.set_pressed_no_signal(false)
        toggle.set_pressed_no_signal(true)

        if !gameData.menu:
            interface.tooltipMode = 2

    delaySlider.value = preferences.tooltipDelay

    if !gameData.menu:
        interface.tooltipDelay = preferences.tooltipDelay



    if preferences.map:
        map.set_pressed_no_signal(true)
        if !gameData.menu:
            hud.ToggleLocation(true)
    else:
        map.set_pressed_no_signal(false)
        if !gameData.menu:
            hud.ToggleLocation(false)

    if preferences.time:
        time.set_pressed_no_signal(true)
        if !gameData.menu:
            hud.ToggleTime(true)
    else:
        time.set_pressed_no_signal(false)
        if !gameData.menu:
            hud.ToggleTime(false)

    if preferences.FPS:
        fps.set_pressed_no_signal(true)
        if !gameData.menu:
            hud.ToggleFPS(true)
    else:
        fps.set_pressed_no_signal(false)
        if !gameData.menu:
            hud.ToggleFPS(false)

    if preferences.stats:
        stats.set_pressed_no_signal(true)
        if !gameData.menu:
            hud.ToggleStats(true)
    else:
        stats.set_pressed_no_signal(false)
        if !gameData.menu:
            hud.ToggleStats(false)



    if preferences.season == 1:
        summer.set_pressed_no_signal(true)
        winter.set_pressed_no_signal(false)
    elif preferences.season == 2:
        summer.set_pressed_no_signal(false)
        winter.set_pressed_no_signal(true)

    gameData.season = preferences.season



    if preferences.TOD == 1:
        dawn.set_pressed_no_signal(true)
        day.set_pressed_no_signal(false)
        dusk.set_pressed_no_signal(false)
        night.set_pressed_no_signal(false)
    elif preferences.TOD == 2:
        dawn.set_pressed_no_signal(false)
        day.set_pressed_no_signal(true)
        dusk.set_pressed_no_signal(false)
        night.set_pressed_no_signal(false)
    elif preferences.TOD == 3:
        dawn.set_pressed_no_signal(false)
        day.set_pressed_no_signal(false)
        dusk.set_pressed_no_signal(true)
        night.set_pressed_no_signal(false)
    elif preferences.TOD == 4:
        dawn.set_pressed_no_signal(false)
        day.set_pressed_no_signal(false)
        dusk.set_pressed_no_signal(false)
        night.set_pressed_no_signal(true)

    gameData.TOD = preferences.TOD



    if preferences.weather == 1:
        neutral.set_pressed_no_signal(true)
        dark.set_pressed_no_signal(false)
        rain.set_pressed_no_signal(false)
        storm.set_pressed_no_signal(false)
    elif preferences.weather == 2:
        neutral.set_pressed_no_signal(false)
        dark.set_pressed_no_signal(true)
        rain.set_pressed_no_signal(false)
        storm.set_pressed_no_signal(false)
    elif preferences.weather == 3:
        neutral.set_pressed_no_signal(false)
        dark.set_pressed_no_signal(false)
        rain.set_pressed_no_signal(true)
        storm.set_pressed_no_signal(false)
    elif preferences.weather == 4:
        neutral.set_pressed_no_signal(false)
        dark.set_pressed_no_signal(false)
        rain.set_pressed_no_signal(false)
        storm.set_pressed_no_signal(true)

    gameData.weather = preferences.weather



    if preferences.aurora:
        simulate.set_pressed_no_signal(true)
    else:
        simulate.set_pressed_no_signal(false)

    gameData.aurora = preferences.aurora



    var window = get_window()


    if preferences.monitor == 0:

        window.set_current_screen(0)
        monitors.select(0)

    elif preferences.monitor != 0:

        var monitorCount = DisplayServer.get_screen_count()

        if preferences.monitor <= monitorCount - 1:

            window.set_current_screen(preferences.monitor)
            monitors.select(preferences.monitor)

        else:

            window.set_current_screen(0)
            monitors.select(0)


    if preferences.displayMode == 1:
        fullscreen.set_pressed_no_signal(true)
        windowed.set_pressed_no_signal(false)
        window.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
        sizes.disabled = true


    elif preferences.displayMode == 2:
        fullscreen.set_pressed_no_signal(false)
        windowed.set_pressed_no_signal(true)
        window.set_mode(Window.MODE_WINDOWED)

        if preferences.windowSize == 0:
            window.set_size(DisplayServer.screen_get_size())
        elif preferences.windowSize == 1:
            window.set_size(DisplayServer.screen_get_size() / 1.1)
        elif preferences.windowSize == 2:
            window.set_size(DisplayServer.screen_get_size() / 1.25)
        elif preferences.windowSize == 3:
            window.set_size(DisplayServer.screen_get_size() / 1.5)

        CenterWindow()
        sizes.disabled = false

    sizes.select(preferences.windowSize)



    if preferences.frameLimit == 1:
        fps_60.set_pressed_no_signal(true)
        fps_120.set_pressed_no_signal(false)
        fps_200.set_pressed_no_signal(false)
        fps_300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 60


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 2:
        fps_60.set_pressed_no_signal(false)
        fps_120.set_pressed_no_signal(true)
        fps_200.set_pressed_no_signal(false)
        fps_300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 120


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 3:
        fps_60.set_pressed_no_signal(false)
        fps_120.set_pressed_no_signal(false)
        fps_200.set_pressed_no_signal(true)
        fps_300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 200


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 4:
        fps_60.set_pressed_no_signal(false)
        fps_120.set_pressed_no_signal(false)
        fps_200.set_pressed_no_signal(false)
        fps_300.set_pressed_no_signal(true)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 300


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 5:
        fps_60.set_pressed_no_signal(false)
        fps_120.set_pressed_no_signal(false)
        fps_200.set_pressed_no_signal(false)
        fps_300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(true)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 1000


        if DisplayServer.window_get_vsync_mode() == 0:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

    elif preferences.frameLimit == 6:
        fps_60.set_pressed_no_signal(false)
        fps_120.set_pressed_no_signal(false)
        fps_200.set_pressed_no_signal(false)
        fps_300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(true)

        if !gameData.menu:
            Engine.max_fps = 1000


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



    if preferences.rendering == 1:
        RLow.set_pressed_no_signal(true)
        RMedium.set_pressed_no_signal(false)
        RHigh.set_pressed_no_signal(false)
        RUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteLowRendering(true)

    elif preferences.rendering == 2:
        RLow.set_pressed_no_signal(false)
        RMedium.set_pressed_no_signal(true)
        RHigh.set_pressed_no_signal(false)
        RUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteMediumRendering(true)

    elif preferences.rendering == 3:
        RLow.set_pressed_no_signal(false)
        RMedium.set_pressed_no_signal(false)
        RHigh.set_pressed_no_signal(true)
        RUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteHighRendering(true)

    elif preferences.rendering == 4:
        RLow.set_pressed_no_signal(false)
        RMedium.set_pressed_no_signal(false)
        RHigh.set_pressed_no_signal(false)
        RUltra.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteUltraRendering(true)



    if preferences.lighting == 1:
        LLow.set_pressed_no_signal(true)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteLowLighting(true)

    elif preferences.lighting == 2:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(true)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteMediumLighting(true)

    elif preferences.lighting == 3:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(true)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteHighLighting(true)

    elif preferences.lighting == 4:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteUltraLighting(true)



    if preferences.antialiasing == 1:
        MSAA_Off.set_pressed_no_signal(true)
        MSAA_2x.set_pressed_no_signal(false)
        MSAA_4x.set_pressed_no_signal(false)
        MSAA_8x.set_pressed_no_signal(false)
        nature_AA_Off.disabled = true
        nature_AA_On.disabled = true

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_DISABLED)
            world.NatureAAOff()

    elif preferences.antialiasing == 2:
        MSAA_Off.set_pressed_no_signal(false)
        MSAA_2x.set_pressed_no_signal(true)
        MSAA_4x.set_pressed_no_signal(false)
        MSAA_8x.set_pressed_no_signal(false)
        nature_AA_Off.disabled = false
        nature_AA_On.disabled = false

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_2X)

            if preferences.natureAA == 1:
                world.NatureAAOff()
            elif preferences.natureAA == 2:
                world.NatureAAOn()

    elif preferences.antialiasing == 3:
        MSAA_Off.set_pressed_no_signal(false)
        MSAA_2x.set_pressed_no_signal(false)
        MSAA_4x.set_pressed_no_signal(true)
        MSAA_8x.set_pressed_no_signal(false)
        nature_AA_Off.disabled = false
        nature_AA_On.disabled = false

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_4X)

            if preferences.natureAA == 1:
                world.NatureAAOff()
            elif preferences.natureAA == 2:
                world.NatureAAOn()

    elif preferences.antialiasing == 4:
        MSAA_Off.set_pressed_no_signal(false)
        MSAA_2x.set_pressed_no_signal(false)
        MSAA_4x.set_pressed_no_signal(false)
        MSAA_8x.set_pressed_no_signal(true)
        nature_AA_Off.disabled = false
        nature_AA_On.disabled = false

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_8X)

            if preferences.natureAA == 1:
                world.NatureAAOff()
            elif preferences.natureAA == 2:
                world.NatureAAOn()

    if preferences.natureAA == 1:
        nature_AA_Off.set_pressed_no_signal(true)
        nature_AA_On.set_pressed_no_signal(false)
    elif preferences.natureAA == 2:
        nature_AA_Off.set_pressed_no_signal(false)
        nature_AA_On.set_pressed_no_signal(true)



func GetWindowSizes():
    var index = 0

    for element in windowSizes:
        sizes.add_item(element, index)
        index += 1

func GetMonitors():
    var monitorCount = DisplayServer.get_screen_count()

    for monitor in monitorCount:
        monitors.add_item("Monitor: " + str(monitor))

func CenterWindow():
    var centerPosition = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
    var windowSize = get_window().get_size_with_decorations()
    get_window().set_position(centerPosition - windowSize / 2)

func _on_fullscreen_pressed() -> void :
    var window = get_window()
    window.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
    sizes.disabled = true

    preferences.displayMode = 1
    preferences.Save()
    PlayClick()

func _on_windowed_pressed() -> void :
    var window = get_window()
    window.set_mode(Window.MODE_WINDOWED)
    sizes.disabled = false

    if preferences.windowSize == 0:
        window.set_size(DisplayServer.screen_get_size())
    elif preferences.windowSize == 1:
        window.set_size(DisplayServer.screen_get_size() / 1.1)
    elif preferences.windowSize == 2:
        window.set_size(DisplayServer.screen_get_size() / 1.25)
    elif preferences.windowSize == 3:
        window.set_size(DisplayServer.screen_get_size() / 1.5)

    CenterWindow()

    preferences.displayMode = 2
    preferences.Save()
    PlayClick()

func _on_monitors_item_selected(index: int) -> void :
    var window = get_window()
    var mode = window.get_mode()

    window.set_mode(Window.MODE_WINDOWED)
    window.set_current_screen(index)

    if mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
        window.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)

    elif mode == Window.MODE_WINDOWED:
        if preferences.windowSize == 0:
            window.set_size(DisplayServer.screen_get_size())
        elif preferences.windowSize == 1:
            window.set_size(DisplayServer.screen_get_size() / 1.1)
        elif preferences.windowSize == 2:
            window.set_size(DisplayServer.screen_get_size() / 1.25)
        elif preferences.windowSize == 3:
            window.set_size(DisplayServer.screen_get_size() / 1.5)

        CenterWindow()

    preferences.monitor = index
    preferences.Save()
    PlayClick()

func _on_sizes_item_selected(index: int) -> void :
    var window = get_window()
    window.set_mode(Window.MODE_WINDOWED)
    var option = sizes.get_item_id(index)

    if option == 0:
        window.set_size(DisplayServer.screen_get_size())
    elif option == 1:
        window.set_size(DisplayServer.screen_get_size() / 1.1)
    elif option == 2:
        window.set_size(DisplayServer.screen_get_size() / 1.25)
    elif option == 3:
        window.set_size(DisplayServer.screen_get_size() / 1.5)

    CenterWindow()

    preferences.windowSize = index
    preferences.Save()
    PlayClick()



func _on_master_slider_value_changed(value):

    preferences.masterVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(masterBus, linear_to_db(value))
    AudioServer.set_bus_mute(masterBus, value < 0.1)

func _on_ambient_slider_value_changed(value):

    preferences.ambientVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(ambientBus, linear_to_db(value))
    AudioServer.set_bus_mute(ambientBus, value < 0.1)

func _on_music_slider_value_changed(value):

    preferences.musicVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(musicBus, linear_to_db(value))
    AudioServer.set_bus_mute(musicBus, value < 0.1)

func _on_music_off_pressed() -> void :

    gameData.musicPreset = 1
    preferences.musicPreset = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_dynamic_pressed() -> void :

    gameData.musicPreset = 2
    preferences.musicPreset = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_shelter_pressed() -> void :

    gameData.musicPreset = 3
    preferences.musicPreset = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_area_05_pressed() -> void :

    gameData.musicPreset = 4
    preferences.musicPreset = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_border_pressed() -> void :

    gameData.musicPreset = 5
    preferences.musicPreset = 5
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_vostok_pressed() -> void :

    gameData.musicPreset = 6
    preferences.musicPreset = 6
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()



func _on_interpolate_off_pressed():

    preferences.interpolate = false
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        camera.interpolate = false

func _on_interpolate_on_pressed():

    preferences.interpolate = true
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        camera.interpolate = true

func _on_fov_slider_value_changed(value):

    preferences.baseFOV = value
    preferences.Save()


    gameData.baseFOV = value

func _on_headbob_slider_value_changed(value):

    preferences.headbob = clampf(value, 0.1, 2.0)
    preferences.Save()


    gameData.headbob = clampf(value, 0.1, 2.0)



func _on_look_slider_value_changed(value):

    preferences.lookSensitivity = value
    preferences.Save()


    gameData.lookSensitivity = value

func _on_aim_slider_value_changed(value):

    preferences.aimSensitivity = value
    preferences.Save()


    gameData.aimSensitivity = value

func _on_scope_slider_value_changed(value):

    preferences.scopeSensitivity = value
    preferences.Save()


    gameData.scopeSensitivity = value



func _on_exposure_slider_value_changed(value):

    preferences.exposure = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_brightness = value

func _on_contrast_slider_value_changed(value):

    preferences.contrast = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_contrast = value

func _on_saturation_slider_value_changed(value):

    preferences.saturation = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_saturation = value



func _on_sharpness_slider_value_changed(value: float) -> void :

    var remapValue = remap(value, 0, 0.5, 0.5, 0)


    preferences.sharpness = remapValue
    preferences.Save()


    if !gameData.menu:
        RenderingServer.viewport_set_fsr_sharpness(currentRID, remapValue)



func _on_hover_pressed():

    preferences.tooltip = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        interface.tooltipMode = 1

func _on_toggle_pressed():

    preferences.tooltip = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        interface.tooltipMode = 2

func _on_delay_slider_value_changed(value):

    preferences.tooltipDelay = value
    preferences.Save()


    if !gameData.menu:
        interface.tooltipDelay = value



func _on_map_toggled(_toggled_on):

    preferences.map = _toggled_on
    preferences.Save()
    PlayClick()


    if _toggled_on:
        if !gameData.menu:
            hud.ToggleLocation(true)
    else:
        if !gameData.menu:
            hud.ToggleLocation(false)

func _on_time_toggled(_toggled_on):

    preferences.time = _toggled_on
    preferences.Save()
    PlayClick()


    if _toggled_on:
        if !gameData.menu:
            hud.ToggleTime(true)
    else:
        if !gameData.menu:
            hud.ToggleTime(false)

func _on_fps_toggled(_toggled_on):

    preferences.FPS = _toggled_on
    preferences.Save()
    PlayClick()


    if _toggled_on:
        if !gameData.menu:
            hud.ToggleFPS(true)
    else:
        if !gameData.menu:
            hud.ToggleFPS(false)

func _on_stats_toggled(_toggled_on):

    preferences.stats = _toggled_on
    preferences.Save()
    PlayClick()


    if _toggled_on:
        if !gameData.menu:
            hud.ToggleStats(true)
    else:
        if !gameData.menu:
            hud.ToggleStats(false)



func _on_summer_pressed():

    gameData.season = 1
    preferences.season = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_winter_pressed():

    if gameData.isWater:
        summer.button_pressed = true
        winter.button_pressed = false
        PlayError()
        return


    gameData.season = 2
    preferences.season = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()



func _on_dawn_pressed():

    gameData.TOD = 1
    preferences.TOD = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_day_pressed():

    gameData.TOD = 2
    preferences.TOD = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_dusk_pressed():

    gameData.TOD = 3
    preferences.TOD = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_night_pressed():

    gameData.TOD = 4
    preferences.TOD = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()



func _on_neutral_pressed():

    gameData.weather = 1
    preferences.weather = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_dark_pressed():

    gameData.weather = 2
    preferences.weather = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_rain_pressed():

    gameData.weather = 3
    preferences.weather = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()

func _on_storm_pressed():

    gameData.weather = 4
    preferences.weather = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        UpdateWorld()



func _on_simulate_toggled(toggled_on):

    if toggled_on:
        gameData.aurora = true
        preferences.aurora = true
        preferences.Save()
        PlayClick()
    else:
        gameData.aurora = false
        preferences.aurora = false
        preferences.Save()
        PlayClick()


    if !gameData.menu:
        UpdateWorld()



func _on_r_low_pressed() -> void :

    preferences.rendering = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteLowRendering(true)

func _on_r_medium_pressed() -> void :

    preferences.rendering = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteMediumRendering(true)

func _on_r_high_pressed() -> void :

    preferences.rendering = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteHighRendering(true)

func _on_r_ultra_pressed() -> void :

    preferences.rendering = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteUltraRendering(true)



func _on_l_low_pressed() -> void :

    preferences.lighting = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteLowLighting(true)

func _on_l_medium_pressed() -> void :

    preferences.lighting = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteMediumLighting(true)

func _on_l_high_pressed() -> void :

    preferences.lighting = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteHighLighting(true)

func _on_l_ultra_pressed() -> void :

    preferences.lighting = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteUltraLighting(true)



func _on_msaa_off_pressed() -> void :

    preferences.antialiasing = 1
    preferences.Save()
    PlayClick()


    nature_AA_Off.disabled = true
    nature_AA_On.disabled = true


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_DISABLED)
        world.NatureAAOff()

func _on_msaa_2x_pressed() -> void :

    preferences.antialiasing = 2
    preferences.Save()
    PlayClick()


    nature_AA_Off.disabled = false
    nature_AA_On.disabled = false


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_2X)

        if preferences.natureAA == 1:
            world.NatureAAOff()
        elif preferences.natureAA == 2:
            world.NatureAAOn()

func _on_msaa_4x_pressed() -> void :

    preferences.antialiasing = 3
    preferences.Save()
    PlayClick()


    nature_AA_Off.disabled = false
    nature_AA_On.disabled = false


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_4X)

        if preferences.natureAA == 1:
            world.NatureAAOff()
        elif preferences.natureAA == 2:
            world.NatureAAOn()

func _on_msaa_8x_pressed() -> void :

    preferences.antialiasing = 4
    preferences.Save()
    PlayClick()


    nature_AA_Off.disabled = false
    nature_AA_On.disabled = false


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_8X)

        if preferences.natureAA == 1:
            world.NatureAAOff()
        elif preferences.natureAA == 2:
            world.NatureAAOn()

func _on_nature_aa_off_pressed() -> void :

    preferences.natureAA = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.NatureAAOff()

func _on_nature_aa_on_pressed() -> void :

    preferences.natureAA = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.NatureAAOn()



func _on_fps_60_pressed():

    preferences.frameLimit = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 60


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_120_pressed():

    preferences.frameLimit = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 120


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_200_pressed():

    preferences.frameLimit = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 200


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_300_pressed():

    preferences.frameLimit = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 300


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_vsync_pressed():

    preferences.frameLimit = 5
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 1000


    if DisplayServer.window_get_vsync_mode() == 0:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _on_unlimited_pressed():

    preferences.frameLimit = 6
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 1000


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



func _on_menu_pressed():
    if gameData.shelter:
        Loader.SaveCharacter()
        Loader.SaveShelter()

    Loader.LoadScene("Menu")
    Deactivate()
    PlayClick()

func _on_quit_pressed():
    if gameData.shelter:
        Loader.SaveCharacter()
        Loader.SaveShelter()

    Loader.Quit()
    Deactivate()
    PlayClick()



func UpdateWorld():

    if gameData.season == 1:
        neutralText.text = "Neutral"
        darkText.text = "Dark"
        rainText.text = "Rain"
        stormText.text = "Storm"
    elif gameData.season == 2:
        neutralText.text = "Neutral"
        darkText.text = "Dark"
        rainText.text = "Snow"
        stormText.text = "Storm"

    if gameData.menu:
        return


    world.UpdateAmbientSFX()
    hud.UpdateTime()


    if gameData.tutorial:
        world.ExecuteTutorial(true)
        return


    if gameData.shelter:
        world.ExecuteShelter(true)
        return


    if gameData.season == 1:
        world.ExecuteSummer(true)
    elif gameData.season == 2:
        world.ExecuteWinter(true)


    if gameData.weather == 1:

        if gameData.TOD == 1:
            world.ExecuteDawnNeutral(true)

        elif gameData.TOD == 2:
            world.ExecuteDayNeutral(true)

        elif gameData.TOD == 3:
            world.ExecuteDuskNeutral(true)

        elif gameData.TOD == 4:
            world.ExecuteNightNeutral(true)

    else:

        if gameData.TOD == 1:
            world.ExecuteDawnDark(true)

        elif gameData.TOD == 2:
            world.ExecuteDayDark(true)

        elif gameData.TOD == 3:
            world.ExecuteDuskDark(true)

        elif gameData.TOD == 4:
            world.ExecuteNightDark(true)


    world.ResetVFX()


    if gameData.season == 1:
        if gameData.weather == 3:
            world.Rain()
        elif gameData.weather == 4:
            world.Storm()

    elif gameData.season == 2:
        if gameData.weather == 3:
            world.Snow()
        elif gameData.weather == 4:
            world.Blizzard()


    if gameData.weather == 1 && gameData.TOD == 4 && gameData.aurora:
        world.Aurora()



func Deactivate():
    inputs.Deactivate()

    for child in get_children():
        if child is Button || Slider:
            child.mouse_filter = MOUSE_FILTER_IGNORE

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

func PlayError():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)
