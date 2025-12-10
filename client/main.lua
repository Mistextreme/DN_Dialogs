-- Since @es_extended/imports.lua is in shared_scripts, 'ESX' is globally available.
-- Since @ox_lib/init.lua is in shared_scripts, 'lib' is globally available.

local isUiOpen = false

-- Function to close the dialog
local function CloseDialog()
    if not isUiOpen then return end
    
    isUiOpen = false
    SetNuiFocus(false, false)
    
    -- Send close action to UI (Action 'close' is standard for this type of NUI)
    SendNUIMessage({
        action = 'close'
    })

    -- Re-enable HUD as per config
    if Config.Hud and Config.Hud.Enable then
        Config.Hud.Enable()
    end
end

-- Function to open the dialog
-- data structure: { name = "NPC Name", message = "Dialog text", options = { { label = "Option 1", value = "opt1" } } }
local function OpenDialog(data)
    if isUiOpen then return end
    if not data then return print('^1[Dialog Error] No data provided to OpenDialog^0') end

    isUiOpen = true
    SetNuiFocus(true, true)

    -- Disable HUD for cinematic effect
    if Config.Hud and Config.Hud.Disable then
        Config.Hud.Disable()
    end

    -- Send open action and configuration to UI
    SendNUIMessage({
        action = 'open',
        data = {
            name = data.name or "Unknown",
            message = data.message or "...",
            options = data.options or {},
            primaryColor = Config.primaryColor or '#0bff81ff'
        }
    })
end

-- Export to allow other resources to open the dialog
-- Usage: exports['resource_name']:OpenDialog(data)
exports('OpenDialog', OpenDialog)

-- Export to close the dialog programmatically
exports('CloseDialog', CloseDialog)

-- Command for debugging (Only enabled if Config.debug is true)
if Config.debug then
    RegisterCommand('testdialog', function()
        OpenDialog({
            name = "Detective Knight",
            message = "We found something interesting at the docks. Do you want to take a look?",
            options = {
                { label = "Yes, let's go.", serverEvent = "police:investigate" },
                { label = "No, I'm busy.", action = "close" }
            }
        })
    end, false)
end

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================

-- Handle the 'close' callback from JS
RegisterNUICallback('close', function(data, cb)
    CloseDialog()
    cb('ok')
end)

-- Handle option selection
RegisterNUICallback('selectOption', function(data, cb)
    CloseDialog()

    if data then
        -- Handle Client Event Trigger
        if data.clientEvent then
            TriggerEvent(data.clientEvent, data.args)
        end

        -- Handle Server Event Trigger
        if data.serverEvent then
            TriggerServerEvent(data.serverEvent, data.args)
        end
        
        -- Handle Action String (if not using events)
        if data.action == 'close' then
            -- Already closed above
        end
    end

    cb('ok')
end)