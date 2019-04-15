_addon.author = 'arosecra';
_addon.name = 'automaneuver';
_addon.version = '1.0';

require 'common'
require 'ffxi.targets'
require 'logging'
require 'windower.shim'
buffs = require 'windower/res/buffs'
require 'packets'

local handle = AshitaCore:GetHandle()
local maneuver_buffs = {
	[300]=true, 
	[301]=true, 
	[302]=true, 
	[303]=true, 
	[304]=true, 
	[305]=true, 
	[306]=true, 
	[307]=true
};
local automaneuver_options = {}
automaneuver_options["off"]=false
automaneuver_options["debug"]=false

local last_maneuvers = {
		};
		
local function print_maneuver_table(message, t)
	if automaneuver_options.debug then
		local output = "=====" .. message .. "======\n"
		for i,v in pairs(t) do
			output = output .. i .. "   : " .. v .. "\n"
		end
		output = output .. "=====" .. message .. "======\n"
		
		print(output);
	end
end;
	
local function initialize_maneuver_table()
	local result = {}
	for i,v in pairs(maneuver_buffs) do
		local name = buffs[i].en
		result[name] = 0
	end
	return result
end
	
local function reset()
	last_maneuvers = initialize_maneuver_table()
	print_maneuver_table('reseting', last_maneuvers);
end
		
ashita.register_event('load', function() 
	reset();
end);



ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked) 
	
	if automaneuver_options.off then
		return false
	end
	
	if id == 0x00D then
		reset();
	end
	return false;
end);

ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked) 

	if automaneuver_options.off then
		return false
	end
	
    -- Obtain the local player..
    local player = GetPlayerEntity();
    if (player == nil) then
        return false;
    end
    
    -- Obtain the players pet index..
    if (player.PetTargetIndex == 0) then
        return false;
    end
    
    -- Obtain the players pet..
    local pet = GetEntity(player.PetTargetIndex);
    if (pet == nil) then
        return false;
    end
		
	--print(string.format("%04x", id));
	
	if id == 0x00A then
	print(string.format("%04x", id));
	return false;
	end
	
	if id == 0x063 then
		local p = packets_parser.parse_set_update(packet)
		if p.update_type == 0x009 then
			local new_manuevers = initialize_maneuver_table()
			local new_manuevers_count = 0
			local last_manuevers_count = 0
					
			for i,v in ipairs(p.type9.buffs) do
				if maneuver_buffs[v] then
					local man_name = buffs[v].en
					new_manuevers[man_name] = new_manuevers[man_name]+1
				end
			end
			
			for i,v in pairs(new_manuevers) do
				new_manuevers_count = new_manuevers_count + new_manuevers[i]
			end
			
			for i,v in pairs(last_maneuvers) do
				last_manuevers_count = last_manuevers_count + last_maneuvers[i]
			end
					
			if new_manuevers_count < 3 or new_manuevers_count < last_manuevers_count then
				for i,v in pairs(new_manuevers) do
					if new_manuevers[i] < last_maneuvers[i] then
						AshitaCore:GetChatManager():QueueCommand('/ja "' .. i .. '" <me>', 1)
					end
				end
			end
			
			print_maneuver_table('buff gain/loss - old', last_maneuvers);
			print_maneuver_table('buff gain/loss - new', new_manuevers);
			
			last_maneuvers = new_manuevers
		end
	end

	return false;
end);


ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/automaneuver' and args[1] ~= '/automn') then
        return false;
    end
	
	local player = AshitaCore:GetDataManager():GetPlayer();
    if (player == nil or player:GetMainJob() ~= Puppetmaster) then
        return false;
    end
    
    -- Skip invalid commands..
    if (#args <= 1) then
        return true;
    end
    
    -- Do we want to add a trigger..
    if (args[2] == 'on') then
		automaneuver_options.off = false
        return true;
    end
	
    
    -- Do we want to add a trigger..
    if (args[2] == 'off') then
		automaneuver_options.off = true
        return true;
    end
	
    if (args[2] == 'debug') then
		if automaneuver_options.debug then
			automaneuver_options.debug = false
		else
			automaneuver_options.debug = true
		end
        return true;
    end
    
    
    return true;
end);
