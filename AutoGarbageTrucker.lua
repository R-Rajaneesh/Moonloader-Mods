-----------------------------------------------------
-- INFO
-----------------------------------------------------

script_name("AutoGarbageTruck")
script_authors("Rajaneesh R")
script_version("1.0.0")
script_dependencies("SAMPFUNCS ^5.3")
pcall(require, "sflua")

-----------------------------------------------------
-- HEADERS & CONFIG
-----------------------------------------------------

require "lib.moonloader"
require "lib.sampfuncs"
require "lib.vkeys"
require "lib.game.globals"
require "lib.game.keys"
require "lib.game.weapons"
local sampev = require "lib.samp.events"
local inicfg = require "inicfg"
local config_dir_path = getWorkingDirectory() .. "\\config\\"
if not doesDirectoryExist(config_dir_path) then createDirectory(config_dir_path) end
local config_file_path = config_dir_path .. "AutoGarbageTrucker.ini"

config_dir_path = nil

local config_table

if doesFileExist(config_file_path) then
    config_table = inicfg.load(nil, config_file_path)
else
    local new_config = io.open(config_file_path, "w")
    new_config:close()
    new_config = nil

    config_table = { Options = { autoGarbageTruckerEnabled = true } }

    if not inicfg.save(config_table, config_file_path) then
        sampAddChatMessage(
            "---- {AAAAFF}Auto Garbage Truck: {FFFFFF}Config file creation failed - contact the developer for help.", -1)
    end
end

-----------------------------------------------------
-- MAIN SCRIPT
-----------------------------------------------------

local autoGarbageTruckerEnabled = true
local insideTrashMaster = false
local sentPickuptrashCommand = false
function main()
    -- Waiting to meet startup conditions
    repeat wait(50) until isSampAvailable()
    -- repeat wait(50) until string.find(sampGetCurrentServerName(), "Horizon Roleplay")
    sampRegisterChatCommand("agt", function()
        if config_table.Options.autoGarbageTruckerEnabled then
            config_table.Options.autoGarbageTruckerEnabled = false
            if inicfg.save(config_table, config_file_path) then
                autoGarbageTruckerEnabled = config_table.Options.autoGarbageTruckerEnabled
                sampAddChatMessage("--- {AAAAFF}Auto Garbage Trucker : {FFFFFF}Off", -1)
            else
                sampAddChatMessage(
                    "--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}Reminder toggle in config failed - contact the developer for help.",
                    -1)
            end
        else
            config_table.Options.autoGarbageTruckerEnabled = true
            if inicfg.save(config_table, config_file_path) then
                autoGarbageTruckerEnabled = config_table.Options.autoGarbageTruckerEnabled
                sampAddChatMessage("--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}On", -1)
            else
                sampAddChatMessage(
                    "--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}Reminder toggle in config failed - contact the developer for help.",
                    -1)
            end
        end
    end)
    sampAddChatMessage(
        "--- {8d49d1}AutoGarbageTruck" .. script.this.version .. " {FFFFFF}by {8d49d1}Rajaneesh R{FFFFFF} ---", -1)
    while true do
        wait(0)
        if autoGarbageTruckerEnabled and insideTrashMaster and sentPickuptrashCommand == false then
            wait(3500)
            sampSendChat("/pickuptrash")
            sentPickuptrashCommand = true
        end
    end
end

-----------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------

function sampev.onSendEnterVehicle(vehicleid, passenger)
    playerIDResult, PLAYER_ID = sampGetPlayerIdByCharHandle(PLAYER_PED)

    -- VehicleID for TRASHMASTER is 416
    if (vehicleid == 416) and autoGarbageTruckerEnabled then
        insideTrashMaster = true
        pickedUpTrash = true
    end
end

function sampev.onSendExitVehicle(vehicleid)
    if (vehicleid == 416) and pickedUpTrash then
        insideTrashMaster = false
    end
end

function sampev.onServerMessage(c, text)
    if text:match("* You have been paid $450 for picking up the garbage and returning the garbage truck.") then
        pickedUpTrash = false
        insideTrashMaster = false
        sentPickuptrashCommand = false
    end
end
