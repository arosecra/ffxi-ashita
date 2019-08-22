
_addon.author   = 'arosecra';
_addon.name     = 'mbpetbar';
_addon.version  = '1.0.0';

require 'common'


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
	
    return true;
end);

ashita.register_event('render', function()

	local petCount = 0;
	
	local party  = AshitaCore:GetDataManager():GetParty();
	if (party == nil) then
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
						
						imgui.Text(petEntity.Name .. "(" .. name .. ")");
						imgui.Separator();
						
						-- Set the progressbar color for health..
						imgui.PushStyleColor(ImGuiCol_PlotHistogram, 1.0, 0.61, 0.61, 0.6);
						imgui.Text('HP:');
						imgui.SameLine();
						imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
						imgui.ProgressBar(tonumber(petEntity.HealthPercent) / 100, -1, 14);
						imgui.PopStyleColor(2);
											
						imgui.End();
					end
				end
			end
		end   
	end
    
end);