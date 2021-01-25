
_addon.author   = 'arosecra';
_addon.name     = 'multiboxhelper';
_addon.version  = '1.0.0';

require 'common'
require 'stringex'
require 'packets'
require 'ffxi.targets'

local brd = require 'job_brd'
local cor = require 'job_cor'
local geo = require 'job_geo'
local pup = require 'job_pup'
local whm = require 'job_whm'
local nuke = require 'ma_nuke'
local sch = require 'job_sch'
local pld = require 'job_pld'

local movement = require 'act_movement'

local config = {
	ws="undefined",
	party_status_effects = {},
	queued_command = nil,
	cycle = 0
};

--local hotbar_config = {};
--local hotbar_position_config = {};
function msg(s)
    local txt = '\31\200[\31\05MultiboxHelper\31\200]\31\130 ' .. s;
    print(txt);
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
	brd:init_config(config)
	cor:init_config(config)
	geo:init_config(config)
	pld:init_config(config)
	pup:init_config(config)
	sch:init_config(config)
	whm:init_config(config)
	nuke:init_config(config)
	movement:init_config(config)
end);

function band(a, b)
	return bit.band(bit.rshift(a, b), 1)
end

function start_action() 
	config.movement.inAction = true
	if (config.movement.following and autofollowObject.running) then
		autofollowObject.running = false;
		autofollowObject:setAutoRun(false);
		config.movement.inAction = true
	end
end

function end_action()
	config.movement.inAction = false
	if(config.movement.following) then
		local currX = AshitaCore:GetDataManager():GetEntity():GetLocalX(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(0));
		local currZ = AshitaCore:GetDataManager():GetEntity():GetLocalZ(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(0));
		local dist = math.sqrt(math.pow((currX - destX), 2.0) + math.pow((currZ - destZ), 2.0));
		if (dist > 0.5 and dist < 30) then
			autofollowObject:setAutoRun(true)
			autofollowObject.running = true;
		config.movement.inAction = false
		end
		
	end

end

--
-- copied and modified from status to try track debuffs against party for stna-like feature
--
ashita.register_event('incoming_packet', function(id, size, packet)
	local new_party_status_effects = {}
	if (id == 0x76) then
		for i = 0, 4 do
			local userIndex = struct.unpack('H', packet, 8+1 + (i * 0x30));
			
			new_party_status_effects[i] = {}
			
			if (AshitaCore:GetDataManager():GetEntity():GetName(userIndex) ~= nil) then
			
				new_party_status_effects[i].Name = AshitaCore:GetDataManager():GetEntity():GetName(userIndex);
				new_party_status_effects[i].Statuses = {}
				
				for j = 0, 31 do
					local BitMask = bit.band(bit.rshift(struct.unpack('b', packet, bit.rshift(j, 2) + 0x0C + (i * 0x30) + 1), 2 * (j % 4)), 3);
					if (struct.unpack('b', packet, 0x14 + (i * 0x30) + j + 1) ~= -1 or BitMask > 0) then
						local buffid = bit.bor(struct.unpack('B', packet, 0x14 + (i * 0x30) + j + 1), bit.lshift(BitMask, 8));
						
						new_party_status_effects[i].Statuses[j] = {}
						new_party_status_effects[i].Statuses[j].Id = buffid;
						new_party_status_effects[i].Statuses[j].StatusName =	AshitaCore:GetResourceManager():GetString("statusnames", buffid, 2)
						--print('got a status update for ' .. new_party_status_effects[i].Name .. ' ' .. new_party_status_effects[i].Statuses[j].Id .. ' ' .. new_party_status_effects[i].Statuses[j].StatusName)
					end
				end
			end
		end
		config.party_status_effects = new_party_status_effects
	elseif (id == 0x0D) then
		local pkt = {
			id = struct.unpack('i4', packet, 0x04+1), 
			index = struct.unpack('H', packet, 0x08+1),
			update = {
				raw = struct.unpack('B', packet, 0x0A+1)
			},
			heading = struct.unpack('B', packet, 0x0B+1),
			x = struct.unpack('f', packet, 0x0C+1),
			z = struct.unpack('f', packet, 0x14+1),
			race = struct.unpack('B', packet, 0x49+1)
		}
		pkt.update.position = band(pkt.update.raw, 0x01)
		pkt.update.status   = band(pkt.update.raw, 0x02)
		pkt.update.hp       = band(pkt.update.raw, 0x04)
		pkt.update.combat   = band(pkt.update.raw, 0x07)
		pkt.update.name     = band(pkt.update.raw, 0x08)
		pkt.update.look     = band(pkt.update.raw, 0x10)
		pkt.update.mob      = band(pkt.update.raw, 0x0F)
		pkt.update.all      = band(pkt.update.raw, 0x1F)
		pkt.update.despawn  = band(pkt.update.raw, 0x20)
		local e = GetEntity(pkt.index);
		if (e ~= nil) then
			pkt.entity = e
		end
		
		if pkt.entity ~= nil and 
		   pkt.entity.Name == config.movement.followName and
		   pkt.x ~= 0 and
		   pkt.y ~= 0 then
			config.movement.destX = pkt.x
			config.movement.destZ = pkt.z
			--print('updating follow dest')
		end
		
		--print('id ' .. pkt.id)
		--print('index ' .. pkt.index)
		--print('update ' .. pkt.update.raw)
		--
		--print('heading ' .. pkt.heading)
		--print('x ' .. pkt.x)
		--print('z ' .. pkt.z)
		--print('race ' .. pkt.race)
		--if (pkt.entity ~= nil) then
		--	print(pkt.entity.Name)
		--end
	elseif(id == 0x28) then
		local pkt = packets_parser.parse_action(packet)
		--print(pkt.actor_id .. ' ' .. pkt.category)
		local playerEntity = GetPlayerEntity();
		if(playerEntity.ServerId == pkt.actor_id) then
			if pkt.category == 12 or pkt.category == 8 then
				start_action();
			elseif pkt.category == 2 or pkt.category == 4 then
				end_action();
			end
		end
	end
	return false;
end);

ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked) 
	if id == 0x00D then
		config.pup.appliedmaneuvers = false
		config.pld.engaged = false
	end
	
	return false;
end);

function run_command(command)
	if (config.movement.following and autofollowObject.running) then
	else 
		AshitaCore:GetChatManager():QueueCommand(command, 1)
	end
end


ashita.register_event('render', function()
    
	if config.cycle > 0 then
		config.cycle = config.cycle + 1
	end
	if config.cycle > 40 then
		if config.queued_command ~= nil then
			AshitaCore:GetChatManager():QueueCommand(config.queued_command, 1)
		end
		config.cycle = 0
		config.queued_command = nil
	end
	
	pup:render(config)
	pld:render(config)
	movement:render(config)
	
	
end);

-- mbh whm cure
-- mbh whm curega
-- mbh whm cure_t_o_t
-- mbh whm removedebuff
-- mbh whm setbarstatus
-- mbh whm setbarelement
-- mbh whm setboost
-- mbh whm boost
-- mbh whm barelement
-- mbh whm barstatus
--
-- mbh brd addsong [song name]
-- mbh brd singsong [n]
-- mbh brd singdummysong [n]
-- mbh brd setcarolelement [n]
-- mbh brd setthrenodyelement [n]
-- mbh brd threnody1
-- mbh brd threnody2
--
-- mbh cor addroll [roll name]
-- mbh cor roll [n]
--
-- mbh geo setbubble [spell name]
-- mbh geo setluopan [spell name]
-- mbh geo setentrust [spell name]
-- mbh geo bubble
-- mbh geo entrust
-- mbh geo luopan
--
-- mbh pup addmaneuver [element]
-- mbh pup maneuver
ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    -- Skip invalid commands..
    if (args[1] ~= '/multiboxhelper' and args[1] ~= '/mbh') then
        return false;
    end
	
    if (#args <= 1) then
        return true;
    end
	
	local player = AshitaCore:GetDataManager():GetPlayer();
    if (player == nil) then
        return false;
    end
	
	local playerEntity = GetPlayerEntity();
    if (playerEntity == nil) then
        return;
    end

    if (args[2] == 'whm') then
		whm:command(config, args);
	    return true;
    end
    	
    if (args[2] == 'setws') then
		config.ws = args[3]
        return true;
    end
    if (args[2] == 'ws') then
		AshitaCore:GetChatManager():QueueCommand("/ws \"" .. config.ws .. "\" <t>", 1)
        return true;
    end
    if (args[2] == 'pup') then
		pup:command(config, args);
	    return true;
    end
    if (args[2] == 'brd') then
		brd:command(config, args);
	    return true;
    end
    if (args[2] == 'geo') then
		geo:command(config, args);
	    return true;
    end
    if (args[2] == 'sch') then
		sch:command(config, args);
	    return true;
    end
    if (args[2] == 'cor') then
		cor:command(config, args);
	    return true;
    end
    if (args[2] == 'pld') then
		pld:command(config, args);
	    return true;
    end
    if (args[2] == 'nuke') then
		nuke:command(config, args);
	    return true;
    end
	
	if (args[2] == 'follow') then
		config.movement.followName = args[3]
	end
	
	if (args[2] == 'status') then
		local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons();
		for slot = 0, 31, 1 do
			if (status_list[slot] < 255) then
				print(status_list[slot])
			end
		end
	end
	
    return true;
end);
