_addon.author = 'arosecra';
_addon.name = 'extexec';
_addon.version = '1.0';

require 'common'
require 'ffxi.targets'
require 'logging'
require 'windower.shim'
buffs = require 'windower/res/buffs'
items = require 'windower/res/items'
local jobs = require 'windower/res/jobs'

ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/extexec') then
        return false;
    end
	
    if (#args <= 1) then
        return true;
    end    
	
    local player = AshitaCore:GetDataManager():GetPlayer();
    local playerEntity = GetPlayerEntity();
    if (player == nil or playerEntity == nil) then
        return;
    end
    
	local mainjob = jobs[player:GetMainJob()].en
	local name = playerEntity.Name
	
	local values = {
		['NAME'] = name,
		['MAINJOB'] = mainjob
	}
	
	local command = string.gsub(args[2], "%$(%w+)", values)
	AshitaCore:GetChatManager():QueueCommand("/exec " .. command, 1)
    
    return true;
end);
