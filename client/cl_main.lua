--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

_clientPrefix = "(client) RedEM: "

print("(client) EssentialMode: RedM edition loaded")

-- Misc functions
function printClient(message)
    print(_clientPrefix .. message)
end

-- Player first spawn
local firstSpawn = false

Citizen.CreateThread(function()
    while firstSpawn == false do
        local spawned = Citizen.InvokeNative(0xB8DFD30D6973E135 --[[NetworkIsPlayerActive]], PlayerPedId(), Citizen.ResultAsInteger())
        if spawned then
            printClient("Player spawned!")
            TriggerServerEvent("redem:playerActivated")
            firstSpawn = true
        end
    end
end)