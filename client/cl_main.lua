--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

_clientPrefix = "(client) RedEM: "
_drawHUD = true

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

function DrawMoney(x, y, text, r, g, b, a, scaleX, scaleY)    
    SetTextScale(scaleX, scaleY)
    Citizen.InvokeNative(0x50a41ad966910f03, r, g, b, a)
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 2, "CASH_STRING", text, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xd79334a4bb99bad1, str, x, y)
end

-- Draw cash
local money = 0
local bank = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if _drawHUD then
            DrawMoney(0.01, 0.01, money, 255, 255, 255, 255, 0.342, 0.342)
            DrawMoney(0.01, 0.03, bank, 255, 255, 255, 255, 0.342, 0.342)
        end
    end
end)

-- Player loaded
RegisterNetEvent("redem:playerLoaded")
AddEventHandler("redem:playerLoaded", function(_money)
    money = _money
end)

-- Updating
RegisterNetEvent("redem:addMoney")
AddEventHandler("redem:addMoney", function(_money)
    money = _money
end)

RegisterNetEvent("redem:addBank")
AddEventHandler("redem:addBank", function(_money)
    bank = _money
end)

-- Stop drawing
RegisterNetEvent("redem:setDrawUI")
AddEventHandler("redem:setDrawUI", function(status)
    _drawHUD = status
end)