_addon.author = 'arosecra';
_addon.name = 'bstextras';
_addon.version = '1.0';

require 'common'
require 'ffxi.targets'
require 'logging'
monster_abilities = require 'windower4res/monster_abilities'

local handle = AshitaCore:GetHandle()

local mainHandIdleStrategy = {
	[1] = {id=1,name="NoSwap"},
	[2] = {id=2,name="Aymur"},
	[2] = {id=2,name="PetDT"},
	[2] = {id=2,name="Arktoi"}
}


ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/bstextras' and args[1] ~= '/bst') then
        return false;
    end
	
	local player = GetPlayerEntity();
    if (player == nil or player:GetMainJob() ~= Beastmaster) then
        return false;
    end
    
    -- Skip invalid commands..
    if (#args <= 1) then
        return true;
    end
    
    -- Do we want to add a trigger..
    if (args[2] == 'cyclemainhand') then
        
		
        return true;
    end
	
    
    -- Do we want to add a trigger..
    if (args[3] == 'cyclesubhand') then
        
		
        return true;
    end
	
    
    -- Do we want to add a trigger..
    if (args[4] == 'cyclecharmers') then
        
		
        return true;
    end
    
    -- Do we want to add a trigger..
    if (args[5] == 'cyclejug') then
        
		
        return true;
    end
    
    
    return true;
end);