
_addon.name = 'warptome'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');

local function find_warp()
    local party     = AshitaCore:GetDataManager():GetParty();
	local player	= AshitaCore:GetDataManager():GetPlayer();
	local target    = AshitaCore:GetDataManager():GetTarget();
	local zone = AshitaCore:GetResourceManager():GetString('areas', party:GetMemberZone(0))
	
	local distance,found,warp_point_type,npc_name;
	

	local result = {};

	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0) then
			if string.find(e.Name, 'Survival Guide') then
				found = 1;
				npc_name = e.Name;
				warp_point_type = 'Survival Guide'
				
				distance = e.Distance;
				print('\30\110Found: '..npc_name..' Distance: '..math.sqrt(distance));
				if math.sqrt(distance)<6 then break end
			elseif string.find(e.Name, 'Home Point') then
				found = 1;
				npc_name = e.Name;
				warp_point_type = 'Home Point'
				
				
				distance = e.Distance;
				print('\30\110Found: '..npc_name..' Distance: '..math.sqrt(distance));
				if math.sqrt(distance)<6 then break end
			end;
		end
	end

	if found == 1 then 
	
	if math.sqrt(distance)<6 then
		result['Zone'] = zone 
		result['Type'] = warp_point_type
		result['Name'] = npc_name
		
		if string.find(npc_name,'1') then 
			result['Index'] = 1
		elseif string.find(npc_name,'2') then 
			result['Index'] = 2
		elseif string.find(npc_name,'3') then 
			result['Index'] = 3
		elseif string.find(npc_name,'4') then 
			result['Index'] = 4
		elseif string.find(npc_name,'5') then
			result['Index'] = 5
		end
	else
		print("\30\68\Found warp point - but too far! Get within 6 yalms")
		result = nil
	end
	
	else 
	  print("\30\68\No warp point Found")
	end
	return result	
end

local function handle_command(command, nType)
	local args = command:args();
    local cmd = args[2];
	local user = args[3]
	if (#args >=2 and args[1] == '/warptome') then
		
		local result = find_warp()
		if result['Type'] == 'Survival Guide' then
			local qCommand = '/ms sendto ' .. user .. ' /sg warp ' .. result['Zone']
			--print("\30\68\ " .. qCommand)
			AshitaCore:GetChatManager():QueueCommand(qCommand, 1)
		elseif result['Type'] == 'Home Point' then
			local qCommand = '/ms sendto ' .. user .. ' /hp warp ' .. result['Zone'] .. ' ' .. result['Index']
			--print("\30\68\ " .. qCommand)
			AshitaCore:GetChatManager():QueueCommand(qCommand, 1)
		end
		return true;
		
	end
	return false;
end








ashita.register_event('command', handle_command);