

local jobs = require 'windower/res/jobs'
local pup = {}
pup.maneuver_elements = {
	[300]='Fire', 
	[301]='Ice', 
	[302]='Wind', 
	[303]='Earth', 
	[304]='Thunder', 
	[305]='Water', 
	[306]='Light', 
	[307]='Dark'
}

function pup:init_config(config)
	config.pup = {
		maneuvers = {},
		appliedmaneuvers = false,
		autorenewmaneuver = "true",
		lastautorenewtime = 0
	}
end

function pup:command(config, args)
	if (args[3] == 'addmaneuver') then
		if (config.pup.maneuvers['1'] == nil) then
			config.pup.maneuvers['1'] = args[4]
		elseif (config.pup.maneuvers['2'] == nil) then
			config.pup.maneuvers['2'] = args[4]
		elseif (config.pup.maneuvers['3'] == nil) then
			config.pup.maneuvers['3'] = args[4]
		else
			config.pup.maneuvers['1'] = config.pup.maneuvers['2']
			config.pup.maneuvers['2'] = config.pup.maneuvers['3']
			config.pup.maneuvers['3'] = args[4]
		end
		if(config.pup.maneuvers['1'] ~= nil) then
			msg("Set maneuver 1 to " .. config.pup.maneuvers['1'])
		end
		if(config.pup.maneuvers['2'] ~= nil) then
			msg("Set maneuver 2 to " .. config.pup.maneuvers['2'])
		end
		if(config.pup.maneuvers['3'] ~= nil) then
			msg("Set maneuver 3 to " .. config.pup.maneuvers['3'])
		end
	elseif (args[3] == 'maneuver') then
		pup:run_maneuver(config)
	elseif (args[3] == 'autorenewmaneuver') then
		config.pup.autorenewmaneuver = args[4]	
		if (config.pup.autorenewmaneuver == 'false') then
			config.pup.appliedmaneuvers = false
		end
	end
end

function pup:render(config)
	local player = AshitaCore:GetDataManager():GetPlayer();
    local playerEntity = GetPlayerEntity();
    if (player == nil or playerEntity == nil) then
        return;
    end
    
	local mainjob = jobs[player:GetMainJob()].en
    
	if mainjob == 'Puppetmaster' then
		-- do pup stuff here
		if config.pup.appliedmaneuvers and 
			config.pup.autorenewmaneuver == "true" and
			os.time() > config.pup.lastautorenewtime + 12
			then
			if pup:run_maneuver(config) then
				config.pup.lastautorenewtime = os.time()
			end
		end
	end
end




function pup:maneuver(config, maneuver_count, maneuver)
	local result = false
	if(maneuver ~= nil) then
		if(maneuver_count[maneuver] > 0) then
			maneuver_count[maneuver] = maneuver_count[maneuver] -1
		else
			config.pup.appliedmaneuvers = true
			AshitaCore:GetChatManager():QueueCommand("/ja \"" .. maneuver .. " Maneuver\" <me>", 1)
			result = true;
		end
			
	end
	return result
end

function pup:count_current_maneuvers()
	local maneuver_count = {
		['Fire']=0, 
		['Ice']=0, 
		['Wind']=0, 
		['Earth']=0, 
		['Thunder']=0, 
		['Water']=0, 
		['Light']=0, 
		['Dark']=0
	}
	local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons();
	for slot = 0, 31, 1 do
		--print(status_list[slot])
		if status_list[slot] >= 300 and status_list[slot] <=307 then
			local element = pup.maneuver_elements[status_list[slot]]
			maneuver_count[element] = maneuver_count[element] + 1
		end
	end
	return maneuver_count
end

function pup:run_maneuver(config)
	local maneuver_count = pup:count_current_maneuvers()
	
	if pup:maneuver(config, maneuver_count, config.pup.maneuvers['1']) then
		return true;
	end
	if pup:maneuver(config, maneuver_count, config.pup.maneuvers['2']) then
		return true;
	end
	if pup:maneuver(config, maneuver_count, config.pup.maneuvers['3']) then
		return true;
	end
end


return pup