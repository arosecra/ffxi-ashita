

local brd = {}


function brd:init_config(config)
	config.brd = {
		songs = {}
	}
end

function brd:command(config, args)
	if (args[3] == 'addsong') then
		if (config.brd.songs['1'] == nil) then
			config.brd.songs['1'] = args[4]
		elseif (config.brd.songs['2'] == nil) then
			config.brd.songs['2'] = args[4]
		elseif (config.brd.songs['3'] == nil) then
			config.brd.songs['3'] = args[4]
		else
			config.brd.songs['1'] = config.brd.songs['2']
			config.brd.songs['2'] = config.brd.songs['3']
			config.brd.songs['3'] = args[4]
		end
		if(config.brd.songs['1'] ~= nil) then
			msg("Set song 1 to " .. config.brd.songs['1'])
		end
		if(config.brd.songs['2'] ~= nil) then
			msg("Set song 2 to " .. config.brd.songs['2'])
		end
		if(config.brd.songs['3'] ~= nil) then
			msg("Set song 3 to " .. config.brd.songs['3'])
		end
	elseif (args[3] == 'singsong') then
		if config.brd.songs[args[4]] == 'Carol 1' and config.brd.carolelement ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.carolelement .. " Carol\" <me>", 1)
		elseif config.brd.songs[args[4]] == 'Carol 2' and config.brd.carolelement ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.carolelement .. " Carol II\" <me>", 1)
		elseif config.brd.songs[args[4]] ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.songs[args[4]] .. "\" <me>", 1)
		end
	elseif (args[3] == 'setcarolelement') then
		config.brd.carolelement = args[4]
	elseif (args[3] == 'setthrenodyelement') then
		config.brd.threnodyelement = args[4]
	elseif (args[3] == 'threnody1' and config.brd.threnodyelement ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.threnodyelement .. " Threnody\" <t>", 1)
	elseif (args[3] == 'threnody2' and config.brd.threnodyelement ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.threnodyelement .. " Threnody II\" <t>", 1)
	end
end

function brd:render(config)
end

return brd