local Config = {
    Config.ChatResourceName = "Characters",
    Config.Server_Webhook = "https://discord.com/api/webhooks/link-here", --[[ only useful for the example ]]
    Config.Server_Webhook_Name = "Super duper logger", --[[ only useful for the example ]]
}

Citizen.CreateThread(function()
    TriggerClientEvent('chat:addSuggestion', '/char', 'Characters', {
        {name="name",help="The first and last name of your character, or REMOVE to remove your name"}
    })
end)

local char_usernames = {}
local char_username_ids = {}
RegisterCommand('char', function(source, args)
    if string.upper(table.concat( args," ")) == "REMOVE" then
        for _,v in pairs(char_username_ids) do
            if v == source then
                table.remove( char_username_ids, v )
                table.remove( char_usernames, v )
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255,0,0},
                    args = {Config.ChatResourceName, "You have removed your Character name"}
                })
                return;
            end
        end
        TriggerClientEvent('chat:addMessage', source, {
            color = {255,0,0},
            args = {Config.ChatResourceName, "You have no Character name to remove"}
        })
        return;
    end
    if string.len(table.concat(args, " ")) > 20 then
        TriggerClientEvent('chat:addMessage', source {
            color = {255,0,0},
            args = {Config.ChatResourceName, "Character name needs to be less than 20 characters"}
        })
        return;
    end
    for _,v in pairs(char_username_ids) do
        if v == source then
            if char_usernames[v] == table.concat(args, " ") then
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255,0,0},
                    args = {Config.ChatResourceName, "Your Character name is already set to this!"}
                })
                return;
            end
            table.remove( char_username_ids, v )
            table.remove( char_usernames, v )
            table.insert( char_username_ids, source )
            table.insert( char_usernames, table.concat(args, " "))
            TriggerClientEvent('chat:addMessage', source, {
                color = {255,0,0},
                args = {Config.ChatResourceName, "You have changed your Character name to ^5"..table.concat(args, " ")}
            })
            return;
        end
    end
    table.insert(char_username_ids, source)
    table.insert(char_usernames, table.concat(args, " "))
    TriggerClientEvent('chat:addMessage', source, {
        color = {255,0,0},
        args = {Config.ChatResourceName, "You have set your Character name to ^5"..table.concat( args," ")}
    })
    return;
end)


-- //////////////////////////////////////////////////// --
--
--               EXAMPLE OF HOW YOU COULD
--               TIE THIS IN WITH YOUR CHAT
--
-- //////////////////////////////////////////////////// --

RegisterCommand('gme', function(source, args)
    for _,v in pairs(char_username_ids) do
        if v == source then
            Character = char_usernames[v]
            TriggerClientEvent('chat:addMessage', -1, {
                color = nil,
                args = {"^2*", "^2"..Character.." "..table.concat(args, " ")}
            })
            message = "`[GME]["..GetPlayerName(source).."] "..Character.." (#"..source.."): "..table.concat(args, " ").."`"
            PerformHttpRequest(Config.Server_Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.Server_Webhook_Name, content = message}), { ['Content-Type'] = 'application/json' })
            return;
        end
    end
    TriggerClientEvent('chat:addMessage', -1, {
        color = nil,
        args = {"^2*", "^2"..GetPlayerName(source).." "..table.concat(args, " ")}
    })
    message = "`[GME] "..GetPlayerName(source).." (#"..source.."): "..table.concat(args, " ").."`"
    PerformHttpRequest(Config.Server_Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.Server_Webhook_Name, content = message}), { ['Content-Type'] = 'application/json' })
end)