

local geo = {}

geo.spelltargets = {
	["Geo-Regen"] = "<me>",
	["Geo-Refresh"] = "<me>",
	["Geo-Haste"] = "<me>",
	["Geo-Str"] = "<me>",
	["Geo-Dex"] = "<me>",
	["Geo-Vit"] = "<me>",
	["Geo-Agi"] = "<me>",
	["Geo-Int"] = "<me>",
	["Geo-Mnd"] = "<me>",
	["Geo-Chr"] = "<me>",
	["Geo-Fury"] = "<me>",
	["Geo-Barrier"] = "<me>",
	["Geo-Acumen"] = "<me>",
	["Geo-Fend"] = "<me>",
	["Geo-Precision"] = "<me>",
	["Geo-Voidance"] = "<me>",
	["Geo-Focus"] = "<me>",
	["Geo-Attunement"] = "<me>",
	["Geo-Wilt"] = "<t>",
	["Geo-Frailty"] = "<t>",
	["Geo-Fade"] = "<t>",
	["Geo-Malaise"] = "<t>",
	["Geo-Slip"] = "<t>",
	["Geo-Torpor"] = "<t>",
	["Geo-Vex"] = "<t>",
	["Geo-Languor"] = "<t>"
}

function geo:init_config(config)
	config.geo = {}
end

function geo:command(config, args)
	if (args[3] == 'setbubble') then
		config.geo['bubble'] = args[4]
		msg("Set bubble to " .. args[4])
	elseif (args[3] == 'setluopan') then
		config.geo['luopan'] = args[4]
		msg("Set luopan to " .. config.geo['luopan'])
	elseif (args[3] == 'bubble' and config.geo['bubble'] ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.geo['bubble'] .. "\" <me>", 1)
	elseif (args[3] == 'luopan' and config.geo['luopan'] ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.geo['luopan'] .. "\" " .. geospelltargets[config.geo['luopan']], 1)
	end
end


return geo