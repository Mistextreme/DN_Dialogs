Config = {}

Config.debug = true
Config.primaryColor = '#0bff81ff'

Config.Hud = {
    Disable = function()
        DisplayRadar(false)
        DisplayHud(false)
    end,
    Enable = function()
        DisplayRadar(true)
        DisplayHud(true)
    end
}