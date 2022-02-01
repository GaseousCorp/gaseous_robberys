local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local Robbery = {}

RegisterNetEvent("robberys:start",function(index)
    local source = source
    local user_id = vRP.getUserId(source)

    if not Robbery[index] then Robbery[index] = {} end
    if not ((Robbery[index].cooldown or 0) == 0) then
        notify(source, "importante", "O roubo ainda está em cooldown<br>Tempo restante: <b>"..Robbery[index].cooldown.." minutos.</b>")
        return
    end

    if Robberys[index].item_require then
        local itens = Robberys[index].item_require
        if not vRP.tryGetInventoryItem(user_id, itens[1], itens[2]) then
            notify(source, "importante", "Você precisa de "..itens[2].."x "..itens[1])
            return
        end
    end

    local polices = {}
    local players = GetPlayers()
    for i=1, #players do
        local user_id = vRP.getUserId(players[i])
        if user_id then
            if vRP.hasPermission(user_id, Robberys[index].police_perm) then
                polices[#polices + 1] = { user_id = user_id, source = tonumber(players[i]) }
            end
        end
    end
    
    if (#polices - Robberys[index].polices) < Robberys[index].polices  then
        notify(source, "importante", "Quantidade de policias insuficiente<br>Quantidade necessaria: <b>"..Robberys[index].polices.."</b>")
        return
    end

    for i=1, #polices do
        local pl_cfx = polices[i]
        TriggerClientEvent("robberys:add_policeblip", pl_cfx.source, Robberys[index].coords, Robberys[index].name)
        notifyPolice(pl_cfx.source, Robberys[index].name, Robberys[index].coords)
    end
   
    Robbery[index].cooldown = Robberys[index].cooldown

    CreateThread(function()
        while (Robbery[index].cooldown > 0) do
            Robbery[index].cooldown = Robbery[index].cooldown - 1
            Wait(60000)
        end
    end)

    TriggerClientEvent("robberys:cl_start", source, Robberys[index].timer)

    local ply = Player(source)
    ply.state.robbery = true

    SetTimeout(Robberys[index].timer * 1000, function()
        if not ply.state.robbery then return end
        for i=1, #Robberys[index].itens do
            local item = Robberys[index].itens[i]
            vRP.giveInventoryItem(user_id,item[1],item[2])
        end
    end)
end)

RegisterCommand("rtimer", function(source)
    local source = source
    local user_id = vRP.getUserId(source)

    if not vRP.hasPermission(user_id, AdminPermission) then return end
    local coords = GetEntityCoords(GetPlayerPed(source))
    for i=1, #Robberys do
        local index = Robberys[i]
        local distance = #(coords - index.coords)
        if distance <= 15 then  
            local request = vRP.request(source, 'Deseja resetar o cooldown do roubo: '..index.name, 30)
            if request then
                if Robbery[i] then
                    Robbery[i].cooldown = 0
                end
            end
            break
        end
    end
end)

RegisterCommand("crob", function(source)
    local source = source
    local user_id = vRP.getUserId(source)

    if not vRP.hasPermission(user_id, AdminPermission) then return end
    local coords = GetEntityCoords(GetPlayerPed(source))

    local name = vRP.prompt(source, 'Nome do roubo', '')
    if not name or name == nil then return end

    local timer = vRP.prompt(source, 'Tempo para roubar', '')
    timer = tonumber(timer)
    if not timer or timer == nil or timer <= 0 then return end

    local polices = vRP.prompt(source, 'Quantidade de policiais para roubar', '')
    polices = tonumber(polices)
    if not polices or polices == nil or polices <= 0 then return end

    local cooldown = vRP.prompt(source, 'Tempo de cooldown', '')
    cooldown = tonumber(cooldown)
    if not cooldown or cooldown == nil or cooldown <= 0 then return end

    local police_perm = vRP.prompt(source, 'Permissão da policia', '')
    if not police_perm or police_perm == nil then return end

    local type = vRP.prompt(source, 'Tipo de roubo', '')
    if not type or type == nil then return end

    local itens = vRP.prompt(source, 'Item que será dado', '')
    if not type or type == nil then return end

    local amount = vRP.prompt(source, 'Quantidade que será dada', '')
    if not amount or amount == nil then return end

    local message = '{\nname = "'..name..'",\ntimer = '..timer..',\npolices = '..polices..',\ncooldown = '..cooldown..',\ncoords = '..coords..',\npolice_perm = "'..police_perm..'",\ntype = "'..type..'",\nitens = {\n     { "'..itens..'",math.random('..amount..') }\n     }\n     },'

    vRP.prompt(source, 'Resultado', message)
end)

RegisterCommand("roubos", function(source)
    local source = source
    for i=1, #Robberys do
        local index = Robberys[i]
        local color = 69
        local status = "<FONT color='#00cc66'>Disponível"
        if Robbery[i] then
            if Robbery[i].cooldown >= 1 then
                color = 49
                status = "<FONT color='#ff3300'>Indisponível"
            end
        end
        TriggerClientEvent("robberys:add_blip", source, index.coords, status.." <FONT color='#ffffff'>| "..index.name, color)
    end

    notify(source, "sucesso", "Os roubos foram marcados no mapa!")
end)
