

local jobs = require 'windower/res/jobs'
require 'ffxi.recast'
require 'ffxi.targets'

local pld = {}
pld.abilities = {
}

function pld:add_ability(config, ability) 
	config.pld.numberofabilities = config.pld.numberofabilities + 1
	config.pld.abilities[config.pld.numberofabilities] = ability
end

function pld:init_config(config)
	config.pld = {
		engaged = false,
		mode = "tank_no_attack", --tank_no_attack, back_tank, tank_attack, aoe_tank
		nextexectime = 0,
		numberofabilities = -1,
		abilities = {}
	}
	
	pld:add_ability(config, {id=547, ability=false, command="/ma Cocoon <me>" , time=2, status= 93, mp=10})
	pld:add_ability(config, {id=106, ability=false, command="/ma Phalanx <me>" , time=5, status=116, mp=21})
	--pld:add_ability(config, {id= 97, ability=false, command="/ma Reprisal <me>", time=2, status=nil, mp=24})
	pld:add_ability(config, {id=73,  ability=true , command="/ja Shield Bash '<t>'", time=2, status=255, mp=0})
	pld:add_ability(config, {id=75,  ability=true , command="/ja Sentinel <me>"  , time=2, status=62, mp=0})
	pld:add_ability(config, {id=77,  ability=true , command="/ja Rampart <me>"   , time=2, status=255, mp=0})
	pld:add_ability(config, {id=112, ability=false, command="/ma Flash <t>"          , time=1, status=255, mp=25})
	pld:add_ability(config, {id=575, ability=false, command="/ma Jettatura <t>"      , time=1, status=255, mp=37})
	pld:add_ability(config, {id=592, ability=false, command="/ma \"Blank Gaze\" <t>" , time=5, status=255, mp=25})
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
	local player = AshitaCore:GetDataManager():GetPlayer()
    local playerEntity = GetPlayerEntity()
    if (player == nil or playerEntity == nil) then
        return
    end
	
	local target = ashita.ffxi.targets.get_target('t')
    
	local mainjob = jobs[player:GetMainJob()].en
	local subjob = jobs[player:GetSubJob()].en
    
	
	if mainjob == 'Paladin' then
		if config.pld.engaged 
		and os.time() > config.pld.nextexectime
		and target ~= nil 
		and target.Name ~= ''
		and target.TargetIndex ~= 0
		then
			local status = pld:get_status()
			if status.can_act then
				--print("can act")
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
				local command = nil
				local action = pld:get_action_to_perform(config)				
				if action ~= nil then
					local command = action.command
					print(command)
					AshitaCore:GetChatManager():QueueCommand(command, 1)
					config.pld.nextexectime = action.time + 10 + os.time()
				else
					--print("no action")
					config.pld.nextexectime = 10 + os.time()
				end
			else
				--print('deferring action for x seconds')
				config.pld.nextexectime = 10 + os.time()
			end
		end
	end
end

function pld:has_status(status)
	local result = false
	if status < 255 then
		local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons()
		for slot = 0, 31, 1 do
			if (status_list[slot] == status) then
				result = true
			end
		end
	end
	return result

end

function pld:get_action_to_perform(config)
	local result = nil
	
	for i = 0, config.pld.numberofabilities, 1 do
		if ( result == nil and
			 not pld:has_status(config.pld.abilities[i].status) and 
		   (
			(
			    config.pld.abilities[i].ability and 
				ashita.ffxi.recast.get_ability_recast_by_index(config.pld.abilities[i].id) == 0
			)
			or
			(
				not config.pld.abilities[i].ability and 
				ashita.ffxi.recast.get_spell_recast_by_index(config.pld.abilities[i].id) == 0) and
				AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0) > config.pld.abilities[i].mp
		   )
		) then
			result = config.pld.abilities[i]
		end
	end
	
	return result
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
	
	local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons()
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
	return status
end

return pld