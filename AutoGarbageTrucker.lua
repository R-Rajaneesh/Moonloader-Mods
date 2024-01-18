-----------------------------------------------------
-- INFO
-----------------------------------------------------
script_name("AutoGarbageTruck")

script_authors("Rajaneesh R")

script_version("1.1.0")

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

if not doesDirectoryExist(config_dir_path) then

    createDirectory(config_dir_path)

end

local config_file_path = config_dir_path .. "AutoGarbageTrucker.ini"

config_dir_path = nil

local config_table

if doesFileExist(config_file_path) then

    config_table = inicfg.load(nil, config_file_path)

else

    local new_config = io.open(config_file_path, "w")

    new_config:close()

    new_config = nil

    config_table = {Options={autoGarbageTruckerEnabled=true}}

    if not inicfg.save(config_table, config_file_path) then

        sampAddChatMessage(
            "---- {AAAAFF}Auto Garbage Truck: {FFFFFF}Config file creation failed - contact the developer for help.", -1)

    end

end

-----------------------------------------------------
-- MAIN SCRIPT
-----------------------------------------------------

local autoGarbageTruckerEnabled = true

local sentPickuptrashCommand = false

local insideVehicle = false

local donekcp = false

local location = nil

local textSize = 0.75 -- Adjust text size here

local game_resX, game_resY

function main()

    -- Waiting to meet startup conditions

    repeat

        wait(50)

    until isSampAvailable()

    repeat

        wait(50)

    until string.find(sampGetCurrentServerName(), "Horizon Roleplay")

    sampAddChatMessage("--- {8d49d1}AutoGarbageTruck (v" .. script.this.version
                           .. ") {FFFFFF}by {8d49d1}Rajaneesh R{FFFFFF} ---", -1)

    sampTextdrawDelete(520)

    sampRegisterChatCommand("agt", function()

        if config_table.Options.autoGarbageTruckerEnabled then

            config_table.Options.autoGarbageTruckerEnabled = false

            if inicfg.save(config_table, config_file_path) then

                autoGarbageTruckerEnabled = false

                sampAddChatMessage("--- {AAAAFF}Auto Garbage Trucker : {FFFFFF}Off", -1)

            else

                sampAddChatMessage(
                    "--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}Reminder toggle in config failed - contact the developer for help.",
                    -1)

            end

        else

            config_table.Options.autoGarbageTruckerEnabled = true

            if inicfg.save(config_table, config_file_path) then

                autoGarbageTruckerEnabled = true

                sampAddChatMessage("--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}On", -1)
            else

                sampAddChatMessage(
                    "--- {AAAAFF}Auto Garbage Trucker: {FFFFFF}Reminder toggle in config failed - contact the developer for help.",
                    -1)

            end

        end

    end)

    while true do

        wait(0)

        if autoGarbageTruckerEnabled and insideVehicle and not sentPickuptrashCommand then

            -- TRASHMASTER VEHICLE MODEL ID IS 408

            if isCharInAnyCar(PLAYER_PED) then

                if (getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 408) then

                    wait(100)

                    sentPickuptrashCommand = true

                    insideVehicle = true

                    sampSendChat("/pickuptrash")

                end

            end

        end

    end

end

-----------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------

function createGarbageTruckLocation(textToShow)

    local window_resX, window_resY = getScreenResolution()

    game_resX, game_resY = convertWindowScreenCoordsToGameScreenCoords(window_resX, window_resY)

    sampTextdrawCreate(520, textToShow, game_resX - 140, game_resY - 20)

    sampTextdrawSetStyle(520, 2)

    sampTextdrawSetAlign(520, 2)

    sampTextdrawSetLetterSizeAndColor(520, textSize / 4, textSize, 0xFFFFFFFF)

    sampTextdrawSetBoxColorAndSize(520, 1, 0x50000000, 0, game_resY * textSize * #textToShow / 70)

end

function sampev.onSendEnterVehicle(vehicleid, passenger)

    insideVehicle = true

end

function sampev.onSendExitVehicle(vehicleid)

    if (getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 408) and not donekcp then

        donekcp = true

        sampSendChat("/kcp")

        donekcp = false

        insideVehicle = false

        sentPickuptrashCommand = false

        removeWaypoint()

        sampTextdrawDelete(520)

    end

end

function sampev.onServerMessage(c, text)

    if text:match("* You have been paid $450 for picking up the garbage and returning the garbage truck.") then

        insideVehicle = false

        sentPickuptrashCommand = false

        sampTextdrawDelete(520)

    elseif text:match("* Return the garbage truck to the department of sanitation.") then

        sampAddChatMessage("Your have {1BCCFF}picked up garbage{FFFFFF} head back to {FF0000}Ocean Docks.", -1)

        location = "Go back to Ocean Docks"

        createGarbageTruckLocation(location)

    end

end

function sampev.onSetCheckpoint(pos, radius)

    if autoGarbageTruckerEnabled and insideVehicle and sentPickuptrashCommand then

        posx = math.floor(pos.x)

        posy = math.floor(pos.y)

        posz = math.floor(pos.z)

        if (posx == 1423 and posy == -1319 and posz == 13) then

            sampAddChatMessage("Your {1BCCFF}garbage pickup {FFFFFF}location is at {FF0000}Materials Pickup 1.", -1)

            location = "Pickup garbage from Materials Pickup 1."

        else

            if (posx == 1665 and posy == -1003 and posz == 24) then

                sampAddChatMessage("Your {1BCCFF}garbage pickup {FFFFFF}location is at {FF0000}Muholland Intersection.",
                    -1)

                location = "Pickup garbage from Muholland Intersection parking."

            elseif (posx == 1142 and posy == -1351 and posz == 13) then

                sampAddChatMessage("Your {1BCCFF}garbage pickup {FFFFFF}location is behind {FF0000}All Saints.", -1)

                location = "Pickup garbage from the backside of All Saints."

            end

            placeWaypoint(posx, posy, posz)

            createGarbageTruckLocation(location)

        end

    end
end
