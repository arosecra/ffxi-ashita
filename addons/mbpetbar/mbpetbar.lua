
_addon.author   = 'arosecra';
_addon.name     = 'mbpetbar';
_addon.version  = '1.0.0';

require 'common'
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
	
	for i=1,5 do
		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
		local entityId = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i)
		--print(entityId)
		if entityId ~= 0 then
			local entity = GetEntity(entityId)
			if entity ~= nil then
				local petTargetIndex = entity.PetTargetIndex
				if petTargetIndex ~= 0 then
					local petEntity = GetEntity(entity.PetTargetIndex)
					if petEntity ~= nil then
						petCount = petCount + 1
					end
				end
			end
		end
	end 
    
	if petCount > 0 then
		imgui.SetNextWindowPos(position_config[1], position_config[2]);
		imgui.SetNextWindowSize(200, 100, ImGuiSetCond_Always);
		if (imgui.Begin('Pets') == false) then
			imgui.End();
			return
		end
		
		for i=1,5 do
			local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
			local entityId = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i)
			--print(entityId)
			if entityId ~= 0 then
				local entity = GetEntity(entityId)
				if entity ~= nil then
					local petTargetIndex = entity.PetTargetIndex
					if petTargetIndex ~= 0 then
						local petEntity = GetEntity(entity.PetTargetIndex)
						--print(petEntity.Name)
						--print(petEntity.HealthPercent)
						if petEntity ~= nil then
							imgui.Text(petEntity.Name .. "(" .. name .. ")");
							imgui.Separator();
							
							-- Set the progressbar color for health..
							imgui.PushStyleColor(ImGuiCol_PlotHistogram, 1.0, 0.61, 0.61, 0.6);
							imgui.Text('HP:');
							imgui.SameLine();
							imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
							imgui.ProgressBar(tonumber(petEntity.HealthPercent) / 100, -1, 14);
							imgui.PopStyleColor(2);
						end
					end
				end
			end
		end 

												
		imgui.End();		
	end
    
end);