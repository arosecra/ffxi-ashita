_addon.author = 'arosecra';
_addon.name = 'ffxicompanion';
_addon.version = '1.0';

require 'common'
require 'logging'
require 'socket'
require 'packets'

ashita          = ashita or { };
ashita.settings = ashita.settings or { };

if (ashita.settings.JSON == nil) then
    ashita.settings.JSON = require('json.json');
end

local handle = AshitaCore:GetHandle()
local sock;	
local last_details = {}
	
ashita.register_event('load', function() 

end);

ashita.register_event('unload', function() 
	--if sock ~= nil then
	--	sock:close();
	--end
end);

--ashita.register_event('command', function(cmd, nType)
--    -- Skip commands that we should not handle..
--    local args = cmd:args();
--        
--    return true;
--end);

ashita.register_event('prerender', function()
	
	local player = GetPlayerEntity();
    if (player == nil) then
        return;
    end
	
	local new_details = {
		[1] = {
			name = player.Name,
			hpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(0),
			mpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMPP(0),
--			tp = (AshitaCore:GetDataManager():GetParty():GetMemberCurrentTP(0) / 3000) * 100
		}
	}
	
	--str 0, +str is 7, 14 is primary att, 5 is defense, 16+ looks to be garbage
	--strength, agility, etc: AshitaCore:GetDataManager():GetPlayer():GetStat(1)
	--local playerhp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0);
	--local playermhp = AshitaCore:GetDataManager():GetPlayer():GetHealthMax();
	--local playerhpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(0);
	--local playermp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0);
	--local playermpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMPP(0);
	--local playertp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentTP(0);
	
	
	if AshitaCore:GetDataManager():GetPlayer().PetTargetIndex ~= 0 then
		local pet = GetEntity(player.PetTargetIndex);
		
		new_details[2] = {
			name = pet.Name,
			hpp = pet.HealthPercent,
			mpp = AshitaCore:GetDataManager():GetPlayer():GetPetMP(),
--			tp  = (AshitaCore:GetDataManager():GetPlayer():GetPetTP() / 3000) * 100
		}
	end
	
	local send_update = false
	
	for k,v in pairs(new_details) do
		if last_details[k] == nil then
			send_update = true;
		else
			if last_details[k].hpp ~= new_details[k].hpp or 
			   last_details[k].mpp ~= new_details[k].mpp or
			   last_details[k].tp ~= new_details[k].tp
			then
				send_update = true
			end
		end
	end
	
	if send_update then
		local data = ashita.settings.JSON:encode_pretty(new_details, nil, { pretty = true, align_keys = false, indent = '    ' });
	
		--local sock = socket.connect('localhost', '11000');
		--if sock ~= nil then
		--	sock:send(data);
		--	sock:close();
		--end
		
		local f = io.open('\\\\.\\pipe\\testpipe', 'w');
		if (f == nil) then
			error('Failed to save configuration.');
		else 
			f:write(data);
			f:flush();
			f:close();
		end

	end
	
	last_details = new_details;
	
end);

