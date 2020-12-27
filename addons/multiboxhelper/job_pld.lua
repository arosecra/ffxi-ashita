

local jobs = require 'windower/res/jobs'
require 'ffxi.recast'

local pld = {}
pld.statuses = {
	['KO']=0, 
	['SLEEP']=2, 
	['SILENCE']='Wind', 
	[303]='Earth', 
	[304]='Thunder', 
	[305]='Water', 
	[306]='Light', 
	[307]='Dark'
}

function pld:init_config(config)
	config.pld = {
		engaged = false,
		mode = "tank_no_attack", --tank_no_attack, back_tank, tank_attack, aoe_tank
		nextexectime = 0
	}
end

function pld:command(config, args)

	if (args[3] == 'preengage') then
	
	elseif (args[3] == 'engage') then
		config.pld.nextexectime = os.time()
		config.pld.engaged = true
	elseif (args[3] == 'disengage') then
		config.pld.engaged = false
	elseif (args[3] == 'setmode') then
		config.pld.mode = args[4]
	end
end

function pld:render(config)
	local player = AshitaCore:GetDataManager():GetPlayer();
    local playerEntity = GetPlayerEntity();
    if (player == nil or playerEntity == nil) then
        return;
    end
    
	local mainjob = jobs[player:GetMainJob()].en
	local subjob = jobs[player:GetSubJob()].en
    
	if mainjob == 'paladin' then
		if config.pld.engaged 
		and os.time() > config.pld.nextexectime
		then
			local status = get_status()
			if status.can_act then
			--am i in range?
			
			--if it is off cooldown, should i shield bash?
			
			-- do i need to use an item?
			
			--do i need to emergency cure myself?
		
			--do i need to buff myself?
				--sentinel
				--palisade
				--phalanx
				--cocoon
			
			
			
			--what hate tools are off cool down?
				-- flash
				-- jettatura
				-- blank gaze
		
			end
		end
	end
end

function pld:get_status()
	local status = {
	}
	status.dead = false
	status.sleep = false
	status.silence = false
	status.terror = false
	status.amnesia = false
	status.stun = false
	status.charm = false
	status.petrification = false
	status.can_act = true
	
	local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons();
    for slot = 0, 31, 1 do
		--print(status_list[slot])
		if status_list[slot] == 0 then
			status.dead = true
			status.can_act = false
		end
		if status_list[slot] == 2 then
			status.sleep = true
			status.can_act = false
		end
		if status_list[slot] == 6 then
			status.silence = true
			status.can_act = false
		end
		if status_list[slot] == 7 then
			status.petrification = true
			status.can_act = false
		end
		if status_list[slot] == 10 then
			status.stun = true
			status.can_act = false
		end
		if status_list[slot] == 14 then
			status.charm = true
			status.can_act = false
		end
		if status_list[slot] == 16 then
			status.amnesia = true
			status.can_act = false
		end
		if status_list[slot] == 17 then
			status.charm = true
			status.can_act = false
		end
		if status_list[slot] == 28 then
			status.terror = true
			status.can_act = false
		end
    end

end

return pld