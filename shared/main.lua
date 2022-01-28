Robberys = {
    {
        name = "Ammunation",
        timer = 25,
        polices = -2,
        cooldown = 50,
        coords = vector3(23.74945, -1105.701, 29.7854),
        police_perm = "Police",
        -- item_require = { "lockpick", 5 },
        type = "ammunation",
        itens = {
             { "dinheirosujo",math.random(50000) }
        }
    },
    {
        name = "Ammunation 2/2",
        timer = 5,
        polices = 3,
        police_perm = "Police",
        cooldown = 60,
        coords = vector3(809.103271, -2159.353760, 29.616821),
        type = "ammunation",
        itens = {
            { "dinheirosujo",math.random(80000) }
        }
    },
}

RobberysRules = {
    ammunation = {
        polices = { 2, 3 }, -- min | max
        thief = { 2 , 2 } -- min | max
    }
}

RobberysInfosKey = true

notifyPolice = function(source,name,coords) -- nao troque o nome
    -- coloque o evento do seu notify push
    TriggerClientEvent("NotifyPush",source,{ code = 31, title = "Roubo a(o) "..name, x = coords.x, y = coords.y, z = coords.z })
end

notify = function(source,css,value) -- nao troque o nome
    -- coloque o evento do seu notify
    TriggerClientEvent("Notify", source, css, value)
end