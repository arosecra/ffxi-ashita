
_addon.name = 'partyfollow'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');

local function handle_command(command, nType)
	local args = command:args();
	if (#args ==1 and args[1] == '/partyfollow') then
		--print(args[1] .. ' ' .. args[2])
	
		--if i am not a member of a party, run /ms ignoreself on
		--else run /ms ignoreself off
		local player = AshitaCore:GetDataManager():GetPlayer();
		local party  = AshitaCore:GetDataManager():GetParty();
		local playerEntity = GetPlayerEntity()
		local members = 0
		if (party == nil) then
			return;
		else
		end
		
		for i=1,5 do
			local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
			if (name ~= "") then
				members = members + 1
			end
		end
		
		
		if (members == 0) then
			print('Ignoring self')
			AshitaCore:GetChatManager():QueueCommand("/ms follow off", 1)
		else
			AshitaCore:GetChatManager():QueueCommand("/ms follow on", 1)
		end
	
		return true;
		
	end
	return false;
end

ashita.register_event('command', handle_command);