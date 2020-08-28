

local cor = {}


function cor:init_config(config)
	config.cor = {
		rolls = {}
	}
end

function cor:command(config, args)
	if (args[3] == 'addroll') then
		if (config.cor.rolls['1'] == nil) then
			config.cor.rolls['1'] = args[4]
		elseif (config.cor.rolls['2'] == nil) then
			config.cor.rolls['2'] = args[4]
		else
			config.cor.rolls['1'] = config.cor.rolls['2']
			config.cor.rolls['2'] = args[4]
		end
		if(config.cor.rolls['1'] ~= nil) then
			msg("Set roll 1 to " .. config.cor.rolls['1'])
		end
		if(config.cor.rolls['2'] ~= nil) then
			msg("Set roll 2 to " .. config.cor.rolls['2'])
		end
	elseif (args[3] == 'roll') then
		AshitaCore:GetChatManager():QueueCommand("/ja \"" .. config.cor.rolls[args[4]] .. "\" <me>", 1)
	end
end

function cor:render(config)
end

return cor