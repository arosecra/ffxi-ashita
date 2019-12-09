
_addon.author   = 'arosecra';
_addon.name     = 'mbpetbar';
_addon.version  = '1.0.0';

require 'common'
local jobs = require 'windower/res/jobs'
local addon_settings = require 'addon_settings'
local last_player_entity = nil
local position_config = {}

ashita.register_event('load', function()
end);

ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/mbpetbar') then
        return false;
    end
	        
    -- Skip invalid commands..
    if (#args <= 1) then
        return true;
    end
	
    if (args[2] == 'list') then

        return true;
    end
	
    return false;
end);

ashita.register_event('render', function()

	local petCount = 0;
	
	local party  = AshitaCore:GetDataManager():GetParty();
	local playerEntity = GetPlayerEntity()
	if (party == nil or playerEntity == nil) then
		last_player_entity = nil	
		position_config = {};
		return;
	end
	if last_player_entity == nil then
		--addon_settings.onload(addon_name, config_filename, default_config_object, create_if_dne, check_for_player_entity, user_specific)
		position_config = addon_settings.onload(_addon.name, 'imgui', {}, true, true, true)
	end
	if position_config[1] == nil then
		return;
	end
	
	for i=0,5 do
		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
		local entityId = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i)
		local mainjob = jobs[AshitaCore:GetDataManager():GetParty():GetMemberMainJob(i)].en
		--print(mainjob)
		if mainjob == "Beastmaster" or
			mainjob == "Puppetmaster" or
			mainjob == "Summoner" or
			mainjob == "Geomancer" 
			then
			petCount = petCount + 1
		end
	end 
    
	if petCount > 0 then
		imgui.SetNextWindowPos(position_config[1], position_config[2]);
		imgui.SetNextWindowSize(200, 100, ImGuiSetCond_Always);
		if (imgui.Begin('Pets') == false) then
			imgui.End();
			return
		end
		
		for i=0,5 do
			local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
			local entityId = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i)
			local mainjob = jobs[AshitaCore:GetDataManager():GetParty():GetMemberMainJob(i)].en
			--print(entityId)
			if entityId ~= 0 then
				local entity = GetEntity(entityId)
				if entity ~= nil then
					local petTargetIndex = entity.PetTargetIndex
					if petTargetIndex ~= 0 then
						local petEntity = GetEntity(entity.PetTargetIndex)
						if petEntity ~= nil then
							imgui.Text(name .. "(" .. petEntity.Name .. ")");
							imgui.SameLine(175);
							if petEntity.HealthPercent == 100 then
								imgui.Text(petEntity.HealthPercent)
							elseif petEntity.HealthPercent < 10 then
								imgui.Text("  " .. petEntity.HealthPercent)
							else
								imgui.Text(" " .. petEntity.HealthPercent)
							end
						end
					elseif mainjob == "Beastmaster" or
							mainjob == "Puppetmaster" or
							mainjob == "Summoner" or
							mainjob == "Geomancer" then
						imgui.Text(name .. "(None)");
						imgui.SameLine(175);
						imgui.Text("  0")
					end
				end
			end
		end 

												
		imgui.End();		
	end
    
end);