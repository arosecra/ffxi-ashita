
_addon.name = 'sneakinvis'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');
local jobs = require 'windower/res/jobs'

local function handle_command(command, nType)
	local args = command:args();
	if (#args ==1 and args[1] == '/sneakinvis') then
		local player = AshitaCore:GetDataManager():GetPlayer();
		local mainJob = jobs[player:GetMainJob()].en
		local subJob  = jobs[player:GetSubJob()].en
		
		local command = ""
		if mainJob == "Dancer" or subJob == "Dancer" then
			command = "/exec DancerSneakInvis.txt"
		elseif mainJob == "White Mage" or 
		       mainJob == "Red Mage" or 
			   mainJob == "Scholar" or
			   subJob == "White Mage" or 
		       subJob == "Red Mage" or 
			   subJob == "Scholar" then
			
			command = "/exec MageSneakInvis.txt"
		end
		
		AshitaCore:GetChatManager():QueueCommand(command, 1)
	end
	return false;
end

ashita.register_event('command', handle_command);