----------------------------------------------------------------------
-- INFO
----------------------------------------------------------------------
script_name("Calculator")

script_authors("Rajaneesh R")

script_description("Calculator better than default HZG")

script_version("1.0.0")

----------------------------------------------------------------------
-- HEADERS & CONFIG
----------------------------------------------------------------------

-- NA

----------------------------------------------------------------------
-- MAIN SCRIPT
----------------------------------------------------------------------
function main()
    repeat
        wait(50)
    until isSampAvailable()

    repeat
        wait(50)
    until string.find(sampGetCurrentServerName(), "Horizon Roleplay")
    sampAddChatMessage(
        "---- {8d49d1}Calculator (v" .. script.this.version .. ") {ffffff}by {8d49d1}Rajaneesh R{ffffff} ----", -1)
    sampRegisterChatCommand("calc", function(args)
        if not (string.match(args, "[A-za-z]")) then
            local equation = loadstring("return " .. args)
            result = equation()
            sampAddChatMessage("[{4b43fb}CALCULATOR{ffffff}] " .. args .. " = " .. result, -1)
        else
            sampAddChatMessage("[{4b43fb}CALCULATOR{ffffff}] {ff0000}Invalid Equations", -1)
        end
    end)
    while true do
        wait(0)
    end
end
