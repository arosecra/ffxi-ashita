_addon.author = 'arosecra';
_addon.name = 'automaneuver';
_addon.version = '1.0';

require 'common'
require 'ffxi.targets'
require 'logging'
require 'windower.shim'
buffs = require 'windower/res/buffs'
items = require 'windower/res/items'
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
local LIGHT_MANUEVER = buffs[306].en
local FIRE_MANUEVER = buffs[300].en

local automaneuver_options = {};
automaneuver_options["off"]=false
automaneuver_options["debug"]=false

local attachments = {
	  [1] = {id=1,   name="Strobe"},
	  [9] = {id=9,   name="Strobe II"},
	  [3] = {id=3,   name="Inhibitor"},
	 [11] = {id=11,  name="Inhibitor II"},
	 [14] = {id=14,  name="Speedloader"},
	 [15] = {id=15,  name="Speedloader II"},
	[194] = {id=194, name="Flashbulb"}  
};

local automaton_raw_items = {}
local automaton_items = {
	heads = {},
	frames = {},
	attachments = {},
	attachment_families = {}
}

local inhibitors = { [3]=true, [11]=true };
local strobes = { [1]=true, [9]=true };
local speedloaders = { [14]=true, [15]=true };
local flashbulbs = { [194]=true };

local heads = {
	[1] = {id=1, name="Harlequinn"},
	[2] = {id=2, name="Valoredge"},
	[3] = {id=3, name="Sharpsot"},
	[4] = {id=4, name="Stormwalker"},
	[5] = {id=5, name="Soulsoother"},
	[6] = {id=6, name="Spiritreaver"},
}

local bodies = {
	[20] = {id=20, name="Harlequinn"},
	[21] = {id=21, name="Valoredge"},
	[22] = {id=22, name="Sharpsot"},
	[23] = {id=23, name="Stormwalker"}
}

local last_maneuvers = {};

local puppet_recasts = {};
puppet_recasts["flashbulb"]=45
puppet_recasts["strobe"]=30

local auto_state = {}
	
local function initialize_maneuver_table()
	local result = {}
	for i,v in pairs(maneuver_buffs) do
		local name = buffs[i].en
		result[name] = 0
	end
	return result
end

local function reset_auto()
	auto_state = {
		has_inhibitors = false,
		has_strobes = false,
		has_speedloaders = false,
		has_flashbulbs = false,
		last_strobe_time = 0,
		last_flash_time = 0,
		last_action_time = 0,
		last_action_identified = 0
	}
end
	
local function reset_char()
	last_maneuvers = initialize_maneuver_table()
end
		
ashita.register_event('load', function() 
	reset_char();
	reset_auto()
	
	for i,v in pairs(items) do
		if v.category == "Automaton" then
			automaton_raw_items[i] = v
		end
	end
	
	--for i,v in pairs(automaton_raw_items) then
	--	if v < 8224 then
	--		automaton_items
	--	elseif v < 8449 then
	--	
	--	else then
	--	
	--	end
	--end
end);

ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked) 
	if automaneuver_options.off then
		return false
	end
	
	if id == 0x00D then
		reset_char();
	reset_auto()
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
		reset_auto()
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
			
			last_maneuvers = new_manuevers
		end
	end
	
	-- if id == 0x0028 then
	-- 	local p = packets_parser.parse_action(packet)
	-- 	print('action ' .. p.category .. ' ' .. p.param)
	-- end
	
	if id == 0x0044 then
		local p = packets_parser.parse_charachter_jobs_extra(packet)
		if p.job == 0x012 then
			for i=1, 12 do
				if inhibitors[p.auto.slots[i]] then
					auto_state.has_inhibitors = true;
				end
				
				if strobes[p.auto.slots[i]] then 
					auto_state.has_strobes = true;
				end
				
				if speedloaders[p.auto.slots[i]] then
					auto_state.has_speedloaders = true;
				end
				
				if flashbulbs[p.auto.slots[i]] then
					auto_state.has_flashbulbs = true;
				end
			end
		end
	end
	--
	--if id == 0x000E then
	--return false
	--end
	--
	--print(string.format("%04x", id));
	

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

local function ws_is_due(current_time)
	return false;
end

local function provoke_is_due(current_time)
	return current_time - auto_state.last_strobe_time > 30 and 
		auto_state.has_strobes and last_maneuvers[FIRE_MANUEVER] > 0;
end

local function flashbulb_is_due(current_time)
	return false;
end

ashita.register_event('prerender', function()
    -- Obtain the local player..
    local player = GetPlayerEntity();
    if (player == nil) then
        return;
    end
    
    -- Obtain the players pet index..
    if (player.PetTargetIndex == 0) then
        return;
    end
    
    -- Obtain the players pet..
    local pet = GetEntity(player.PetTargetIndex);
    if (pet == nil) then
        return;
    end
    
    local pettp = AshitaCore:GetDataManager():GetPlayer():GetPetTP();
    local petmp = AshitaCore:GetDataManager():GetPlayer():GetPetMP();
	local mastertp = AshitaCore:GetDataManager():GetPlayer():GetPetTP();
    
	current_time = os.time()
	if pet.Status == 1 and 
		current_time - auto_state.last_action_time > 3 and
		current_time - auto_state.last_action_identified > 3 then
		if provoke_is_due(current_time) then
			print('expecting provoke')
			auto_state.last_action_identified = current_time
		elseif flashbulb_is_due(current_time) then
			--print('expecting flashbulb')
			auto_state.last_action_identified = current_time
		elseif ws_is_due(current_time) then
			--print('expecting ws')
			auto_state.last_action_identified = current_time
		end
		
		
	end
	
end);

ashita.register_event('incoming_text', function(mode, message, modifiedmode, modifiedmessage, blocked)
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
		    
	if string.contains(message, pet.Name) and string.contains(message, "Provoke") then
		auto_state.last_strobe_time = os.time()
		auto_state.last_action_time = os.time()
	end
	
	if string.contains(message, pet.Name) and string.contains(message, 'Flashbulb') then
		auto_state.last_flash_time = os.time()
		auto_state.last_action_time = os.time()
	end
	
	--if string.contains(message, pet.Name) and string.contains(message, "Daze") then
	--	print("Daze")
    --elseif string.contains(message, pet.Name) and string.contains(message, "Arcuballista") then
	--	print("Arcuballista")
    --elseif string.contains(message, pet.Name) and string.contains(message, "Armor Shatterer") then
	--	print("Armor Shatterer")
    --elseif string.contains(message, pet.Name) and string.contains(message, "Armor Piercer") then
	--	print("Armor Piercer")
    --end
	
	return false;
end);

ashita.register_event('render', function()
    -- Obtain the local player..
    local player = GetPlayerEntity();
    if (player == nil) then
        return;
    end
    
    -- Obtain the players pet index..
    if (player.PetTargetIndex == 0) then
        return;
    end
    
    -- Obtain the players pet..
    local pet = GetEntity(player.PetTargetIndex);
    if (pet == nil) then
        return;
    end
    
    -- Display the pet information..
    imgui.SetNextWindowSize(200, 225, ImGuiSetCond_Always);
    if (imgui.Begin('Puppet State') == false) then
        imgui.End();
        return;
    end
            
    imgui.Text('Has Inhibitors: ' .. tostring(auto_state.has_inhibitors));
    imgui.Separator();
    imgui.Text('Has Strobes: ' .. tostring(auto_state.has_strobes));
    imgui.Separator();
    imgui.Text('Has Speedloaders: ' .. tostring(auto_state.has_speedloaders));
    imgui.Separator();
    imgui.Text('Has Flashbulbs: ' .. tostring(auto_state.has_flashbulbs));
    imgui.Separator();
    imgui.Text('Last Strobe: ' .. auto_state.last_strobe_time);
    imgui.Separator();
    imgui.Text('Last Flashbulb: ' .. auto_state.last_flash_time);
    imgui.Separator();
    imgui.Text('Last Action: ' .. auto_state.last_action_time);
    imgui.Separator();
    imgui.Text('Last Action ID: ' .. auto_state.last_action_identified);
    imgui.Separator();
	local header = ""
	local values = ""
	
	for i,v in pairs(last_maneuvers) do
		header = header .. string.sub(i, 1,1)
		values = values .. v
	end
	imgui.Text(header);
	imgui.Text(values);
	imgui.Separator();
    
    imgui.End();
end);
