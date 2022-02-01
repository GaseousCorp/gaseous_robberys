local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local inProgress = false
local timerReaming = 0

CreateThread(function()
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        local coord = GetEntityCoords(ped)
        for i=1, #Robberys do
            local index = Robberys[i]
            local distance = #(coord - index.coords)
            if distance <= 5 then
                idle = 4
                if not inProgress then
                    if not RobberysInfosKey then
                        Text3D(index.coords.x,index.coords.y,index.coords.z, "~r~[E]~w~ PARA INICIAR")
                    else
                        Text3D(index.coords.x,index.coords.y,index.coords.z, "~r~[E]~w~ PARA INICIAR\n~r~[G]~w~ PARA VER REGRAS") 
                        if IsControlJustPressed(0, 47) and distance <= 2 then
                            local rules = RobberysRules[index.type]
                            if rules then
                                TriggerEvent("Notify", "aviso","Minimo de policiais: "..rules.polices[1].."<br>Maximo de policiais: "..rules.polices[2].."<br>Minimo de assaltantes: "..rules.thief[1].."<br>Maximo de assaltantes: "..rules.thief[2])
                                
                            end
                        end
                    end
                    if IsControlJustPressed(0, 38) and distance <= 1 then
                        TriggerServerEvent("robberys:start", i)
                    end
                else
                    Text3D(index.coords.x,index.coords.y,index.coords.z, "TEMPO RESTANTE ~r~"..timerReaming)
                    if not IsEntityPlayingAnim(ped, "anim@heists@ornate_bank@grab_cash", "grab", 3) or not (GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED")) then
                        ClearPedTasksImmediately(ped)
                        PlayAnim(ped, "anim@heists@ornate_bank@grab_cash", "grab",-5,2)
                        SetPedComponentVariation(ped,5,21,0,2)
                    	SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true)
                    end
                end
            end
        end
        Wait(idle)
    end
end)

RegisterNetEvent("robberys:cl_start",function(time)
    if not time then return end
    timerReaming = time
    inProgress = true
    CreateThread(function()
        repeat
            Wait(1000)
            if timerReaming > 0 then
                timerReaming = timerReaming - 1
                if timerReaming == 0 then
                    inProgress = false
                end
            end
        until ( timerReaming == 0)
        ClearPedTasksImmediately(PlayerPedId())
    end)
end)

RegisterCommand("robberys:stop", function()
    if not inProgress then return end
    inProgress = false
    timerReaming = 0
    TriggerEvent("Notify", "importante", "Você cancelou o roubo")
    LocalPlayer.state:set('robbery', false, true)
end)

RegisterNetEvent("robberys:add_policeblip",function(coords,name)
    local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
    SetBlipSprite(blip,161)
    SetBlipAsShortRange(blip,true)
    SetBlipColour(blip,49)
    SetBlipScale(blip,0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("~w~"..name.." | ~r~ AÇÃO")
    EndTextCommandSetBlipName(blip)
    PlaySoundFrontend(-1, "Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
    SetTimeout(120 * 1000, function()
        RemoveBlip(blip)
    end)
end)

RegisterNetEvent("robberys:add_blip",function(coords,text,color)
    local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
    SetBlipSprite(blip,431)
    SetBlipAsShortRange(blip,true)
    SetBlipColour(blip,color)
    SetBlipScale(blip,0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)

    SetTimeout(15 * 1000, function()
        RemoveBlip(blip)
    end)
end)

function Text3D(x,y,z,text)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.25,0.25)
    SetTextColour(255,255,255,150)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function PlayAnim(ped,direct,name,v1,v2)
	local anim = direct
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do Wait(10) end
	TaskPlayAnim(ped,anim,name,v1,v2,-1,0,0, false,false,false)
end

RegisterKeyMapping ( 'robberys:stop' , 'Cancelar roubo' , 'keyboard' , 'F6' )
