
_addon.author   = 'arosecra';
_addon.name     = 'multiboxhelper';
_addon.version  = '1.0.0';

require 'common'
require 'stringex'
require 'packets'
require 'autofollow'
local jobs = require 'windower/res/jobs'
--local addon_settings = require 'addon_settings'
local statuses = {
	[1]  = { name="doom",         spell="Cursna"   , priority=1 },
	[2]  = { name="curse",        spell="Cursna"   , priority=2 },
	[3]  = { name="petrifaction", spell="Sonta"    , priority=3 },
	[4]  = { name="paralysis",    spell="Paralyna" , priority=4 },
	[5]  = { name="plague",       spell="Viruna"   , priority=5 },
	[6]  = { name="silence",      spell="Silena"   , priority=6 },
	[7]  = { name="blindness",    spell="Blindna"  , priority=7 },
	[8]  = { name="poison",       spell="Poisona"  , priority=8 },
	[9]  = { name="diseased",     spell="Viruna"   , priority=9 },
	[10] = { name="sleep",        spell="Cure"     , priority=10},
	[11] = { name="bio",          spell="Erase"    , priority=11},
	[12] = { name="dia",          spell="Erase"    , priority=12},
	[13] = { name="gravity",      spell="Erase"    , priority=13},
	[14] = { name="flash",        spell="Erase"    , priority=14},
	[15] = { name="addle",        spell="Erase"    , priority=15},
	[16] = { name="slow",         spell="Erase"    , priority=16},
	[17] = { name="elegy",        spell="Erase"    , priority=17},
	[18] = { name="requiem",      spell="Erase"    , priority=18},
	[19] = { name="shock",        spell="Erase"    , priority=19},
	[20] = { name="rasp",         spell="Erase"    , priority=20},
	[21] = { name="choke",        spell="Erase"    , priority=21},
	[22] = { name="frost",        spell="Erase"    , priority=22},
	[23] = { name="burn",         spell="Erase"    , priority=23},
	[24] = { name="drown",        spell="Erase"    , priority=24},
	[25] = { name="pyrohelix",    spell="Erase"    , priority=25},
	[26] = { name="cryohelix",    spell="Erase"    , priority=26},
	[27] = { name="anemohelix",   spell="Erase"    , priority=27},
	[28] = { name="geohelix",     spell="Erase"    , priority=28},
	[29] = { name="ionohelix",    spell="Erase"    , priority=29},
	[30] = { name="hydrohelix",   spell="Erase"    , priority=30},
	[31] = { name="luminohelix",  spell="Erase"    , priority=31},
	[32] = { name="noctohelix",   spell="Erase"    , priority=32}
}

local geospelltargets = {
	["Geo-Regen"] = "<me>",
	["Geo-Refresh"] = "<me>",
	["Geo-Haste"] = "<me>",
	["Geo-Str"] = "<me>",
	["Geo-Dex"] = "<me>",
	["Geo-Vit"] = "<me>",
	["Geo-Agi"] = "<me>",
	["Geo-Int"] = "<me>",
	["Geo-Mnd"] = "<me>",
	["Geo-Chr"] = "<me>",
	["Geo-Fury"] = "<me>",
	["Geo-Barrier"] = "<me>",
	["Geo-Acumen"] = "<me>",
	["Geo-Fend"] = "<me>",
	["Geo-Precision"] = "<me>",
	["Geo-Voidance"] = "<me>",
	["Geo-Focus"] = "<me>",
	["Geo-Attunement"] = "<me>",
	["Geo-Wilt"] = "<t>",
	["Geo-Frailty"] = "<t>",
	["Geo-Fade"] = "<t>",
	["Geo-Malaise"] = "<t>",
	["Geo-Slip"] = "<t>",
	["Geo-Torpor"] = "<t>",
	["Geo-Vex"] = "<t>",
	["Geo-Languor"] = "<t>"
}

local maneuver_elements = {
	[300]='Fire', 
	[301]='Ice', 
	[302]='Wind', 
	[303]='Earth', 
	[304]='Thunder', 
	[305]='Water', 
	[306]='Light', 
	[307]='Dark'
}

local config = {
	brd = {
		songs = {}
	},
	cor = {
		rolls = {}
	},
	geo = {
	},
	whm = {
	},
	pup = {
		maneuvers = {},
		appliedmaneuvers = false,
		autorenewmaneuver = "true",
		lastautorenewtime = 0
	},
	ws="undefined",
	follow = {
		destX = nil,
		destZ = nil,
		followName = nil,
		following = nil,
		inAction = false
	}
};
local dataManager = AshitaCore:GetDataManager();
local chatManager = AshitaCore:GetChatManager();

local autofollowObject = autoFollow;

local party_status_effects = {}

--local hotbar_config = {};
--local hotbar_position_config = {};
local function msg(s)
    local txt = '\31\200[\31\05MultiboxHelper\31\200]\31\130 ' .. s;
    print(txt);
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
--	hotbar_config = addon_settings.onload(_addon.name, _addon.name, {}, true, false, false)
    autofollowObject.baseAddress = ashita.memory.read_int32(ashita.memory.find("FFXiMain.dll", 0, "F6C4447A42D905????????D81D????????", 7, 0)); 
	if (autofollowObject.baseAddress) then
		-- Do nothing; Addon was able to load
	else
		print("Unable to find autofollow pointer");
		chatManager:QueueCommand("/addon unload " .. _addon.name, 1);
	end;
end);

function start_action() 
	config.follow.inAction = true
	if (config.follow.following and autofollowObject.running) then
		autofollowObject.running = false;
		autofollowObject:setAutoRun(false);
		config.follow.inAction = true
	end
end

function end_action()
	config.follow.inAction = false
	if(config.follow.following) then
		local currX = dataManager:GetEntity():GetLocalX(dataManager:GetParty():GetMemberTargetIndex(0));
		local currZ = dataManager:GetEntity():GetLocalZ(dataManager:GetParty():GetMemberTargetIndex(0));
		local dist = math.sqrt(math.pow((currX - destX), 2.0) + math.pow((currZ - destZ), 2.0));
		if (dist > 0.5 and dist < 30) then
			autofollowObject:setAutoRun(true)
			autofollowObject.running = true;
		config.follow.inAction = false
		end
		
	end

end

function band(a, b)
	return bit.band(bit.rshift(a, b), 1)
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
		party_status_effects = new_party_status_effects
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
		   pkt.entity.Name == config.follow.followName and
		   pkt.x ~= 0 and
		   pkt.y ~= 0 then
			config.follow.destX = pkt.x
			config.follow.destZ = pkt.z
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
		--print(pkt.actor_id)
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
	end
	
	return false;
end);

local function run_command_after_timer(command)
	AshitaCore:GetChatManager():QueueCommand(command, 1)
end

local function run_cure(cure1, cure2, cure3, cure4, args)
	local lowestHpp = 100;
	local lowestHp = 0;
	local lowestName;
	local hpMissing = 0;
	for i=0,5 do
		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
		local hp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(i)
		local hpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(i)
		if (name ~= "") then
			if (hpp < lowestHpp and hpp > 0) then
				lowestHpp = hpp;
				lowsetHp = hp;
				lowestName = name;
				--local playerEntity = GetEntity(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i))
				hpMissing = (hp/(hpp / 100))-hp;
				print(name .. " " .. hpp .. " " .. hp .. " " .. hpMissing)
			end
		end
	end
	--cure iv = 680
	--cure iii = 364
	if lowestHpp < 100 then
		start_action()
		local command = ""
		if hpMissing > cure4 then
			command = "/ma \"Cure IV\" " .. lowestName
		elseif hpMissing > cure3 then
			command = "/ma \"Cure IV\" " .. lowestName
		elseif hpMissing > cure2 then
			command = "/ma \"Cure IV\" " .. lowestName
		elseif hpMissing > cure1 then
			command = "/ma \"Cure IV\" " .. lowestName
		end
		
		ashita.timer.once(1, run_command_after_timer, command)
	end

end

local function run_cure_t_o_t(args)
end

local function run_remove_debuff(args)

	for istatus,status in ipairs(statuses) do
		
		for i=0,4 do
			if party_status_effects[i] ~= nil then
			
				for j=0,31 do
					if party_status_effects[i].Statuses[j] ~= nil and party_status_effects[i].Statuses[j].StatusName == status.name then
						start_action()
						AshitaCore:GetChatManager():QueueCommand("/ma \"" .. status.spell .. "\" " .. party_status_effects[i].Name, 1)
						break;
					end
				end
			end
		end
	
	end


end

local function run_bard(args)
	if (args[3] == 'addsong') then
		if (config.brd.songs['1'] == nil) then
			config.brd.songs['1'] = args[4]
		elseif (config.brd.songs['2'] == nil) then
			config.brd.songs['2'] = args[4]
		else
			config.brd.songs['1'] = config.brd.songs['2']
			config.brd.songs['2'] = args[4]
		end
		if(config.brd.songs['1'] ~= nil) then
			msg("Set song 1 to " .. config.brd.songs['1'])
		end
		if(config.brd.songs['2'] ~= nil) then
			msg("Set song 2 to " .. config.brd.songs['2'])
		end
	elseif (args[3] == 'singsong') then
		if config.brd.songs[args[4]] == 'Carol 1' and config.brd.carolelement ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.carolelement .. " Carol\" <me>", 1)
		elseif config.brd.songs[args[4]] == 'Carol 2' and config.brd.carolelement ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.carolelement .. " Carol II\" <me>", 1)
		elseif config.brd.songs[args[4]] ~= nil then
			AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.songs[args[4]] .. "\" <me>", 1)
		end
	elseif (args[3] == 'setcarolelement') then
		config.brd.carolelement = args[4]
	elseif (args[3] == 'setthrenodyelement') then
		config.brd.threnodyelement = args[4]
	elseif (args[3] == 'threnody1' and config.brd.threnodyelement ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.threnodyelement .. "\" <t>", 1)
	elseif (args[3] == 'threnody2' and config.brd.threnodyelement ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.threnodyelement .. " II\" <t>", 1)
	end
end

local function run_geo(args)
	if (args[3] == 'setbubble') then
		config.geo['bubble'] = args[4]
		msg("Set bubble to " .. args[4])
	elseif (args[3] == 'setluopan') then
		config.geo['luopan'] = args[4]
		msg("Set luopan to " .. config.geo['luopan'])
	elseif (args[3] == 'bubble' and config.geo['bubble'] ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.geo['bubble'] .. "\" <me>", 1)
	elseif (args[3] == 'luopan' and config.geo['luopan'] ~= nil) then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.geo['luopan'] .. "\" " .. geospelltargets[config.geo['luopan']], 1)
	end
end

local function maneuver(maneuver_count, maneuver)
	local result = false
	if(maneuver ~= nil) then
		if(maneuver_count[maneuver] > 0) then
			maneuver_count[maneuver] = maneuver_count[maneuver] -1
		else
			config.pup.appliedmaneuvers = true
			AshitaCore:GetChatManager():QueueCommand("/ja \"" .. maneuver .. " Maneuver\" <me>", 1)
			result = true;
		end
			
	end
	return result
end

local function count_current_maneuvers()
	local maneuver_count = {
		['Fire']=0, 
		['Ice']=0, 
		['Wind']=0, 
		['Earth']=0, 
		['Thunder']=0, 
		['Water']=0, 
		['Light']=0, 
		['Dark']=0
	}
	local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons();
	for slot = 0, 31, 1 do
		--print(status_list[slot])
		if status_list[slot] >= 300 and status_list[slot] <=307 then
			local element = maneuver_elements[status_list[slot]]
			maneuver_count[element] = maneuver_count[element] + 1
		end
	end
	return maneuver_count
end

local function run_maneuver()
	local maneuver_count = count_current_maneuvers()
	
	if maneuver(maneuver_count, config.pup.maneuvers['1']) then
		return true;
	end
	if maneuver(maneuver_count, config.pup.maneuvers['2']) then
		return true;
	end
	if maneuver(maneuver_count, config.pup.maneuvers['3']) then
		return true;
	end
end

local function run_pup(args)
	if (args[3] == 'addmaneuver') then
		if (config.pup.maneuvers['1'] == nil) then
			config.pup.maneuvers['1'] = args[4]
		elseif (config.pup.maneuvers['2'] == nil) then
			config.pup.maneuvers['2'] = args[4]
		elseif (config.pup.maneuvers['3'] == nil) then
			config.pup.maneuvers['3'] = args[4]
		else
			config.pup.maneuvers['1'] = config.pup.maneuvers['2']
			config.pup.maneuvers['2'] = config.pup.maneuvers['3']
			config.pup.maneuvers['3'] = args[4]
		end
		if(config.pup.maneuvers['1'] ~= nil) then
			msg("Set maneuver 1 to " .. config.pup.maneuvers['1'])
		end
		if(config.pup.maneuvers['2'] ~= nil) then
			msg("Set maneuver 2 to " .. config.pup.maneuvers['2'])
		end
		if(config.pup.maneuvers['3'] ~= nil) then
			msg("Set maneuver 3 to " .. config.pup.maneuvers['3'])
		end
	elseif (args[3] == 'maneuver') then
		run_maneuver()
	elseif (args[3] == 'autorenewmaneuver') then
		config.pup.autorenewmaneuver = args[4]	
		if (config.pup.autorenewmaneuver == 'false') then
			config.pup.appliedmaneuvers = false
		end
	end
end

local function run_whm(args)
	if (args[3] == 'cure') then
		run_cure(100, 250, 500, 600, args)
	elseif (args[3] == 'curega') then
	elseif (args[3] == 'cure_t_o_t') then
		run_cure_t_o_t(args)
	elseif (args[3] == 'removedebuff') then
		run_remove_debuff(args)
	elseif (args[3] == 'setbarstatus') then
		config.whm.barstatus = args[4]
	elseif (args[3] == 'setbarelement') then
		config.whm.barelement = args[4]
	elseif (args[3] == 'setboost') then
		config.whm.boost = args[4]
	elseif (args[3] == 'boost') then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.whm.boost .. "\" <me>", 1)
	elseif (args[3] == 'barstatus') then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.whm.barstatus .. "\" <me>", 1)
	elseif (args[3] == 'barelement') then
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.whm.barelement .. "\" <me>", 1)
	end
end

local function run_cor(args)
	if (args[3] == 'addroll') then
		if (config.cor.rolls['1'] == nil) then
			config.cor.rolls['1'] = args[4]
		elseif (config.cor.rolls['2'] == nil) then
			config.cor.rolls['2'] = args[4]
		else
			config.cor.rolls['1'] = config.cor.rolls['2']
			config.cor.rolls['2'] = args[4]
		end
		if(config.cor.rolls['1'] ~= nil) then
			msg("Set roll 1 to " .. config.cor.rolls['1'])
		end
		if(config.cor.rolls['2'] ~= nil) then
			msg("Set roll 2 to " .. config.cor.rolls['2'])
		end
	elseif (args[3] == 'roll') then
		AshitaCore:GetChatManager():QueueCommand("/ja \"" .. config.cor.rolls[args[4]] .. "\" <me>", 1)
	end
end

ashita.register_event('render', function()
    -- Obtain the local player..
    local player = AshitaCore:GetDataManager():GetPlayer();
    local playerEntity = GetPlayerEntity();
    if (player == nil or playerEntity == nil) then
        return;
    end
    
	local mainjob = jobs[player:GetMainJob()].en
    
	if mainjob == 'Puppetmaster' then
		-- do pup stuff here
		if config.pup.appliedmaneuvers and 
			config.pup.autorenewmaneuver == "true" and
			os.time() > config.pup.lastautorenewtime + 12
			then
			if run_maneuver() then
				config.pup.lastautorenewtime = os.time()
			end
		end
	end
	
	local currX = dataManager:GetEntity():GetLocalX(dataManager:GetParty():GetMemberTargetIndex(0));
	local currZ = dataManager:GetEntity():GetLocalZ(dataManager:GetParty():GetMemberTargetIndex(0));
	
	if  (os.time() >= (autofollowObject.timer + autofollowObject.delay)) then
        autofollowObject.timer = os.time();
	end;
	
	if not autofollowObject.running and 
	   config.follow.destX ~= nil and 
	   config.follow.destZ ~= nil and
	   not config.follow.inAction then
		autofollowObject:setAutoRun(true)
		autofollowObject.running = true;
	end

	-- Has to be ran faster than timing loop
	if (autofollowObject.running) then		
		local dist = math.sqrt(math.pow((currX - config.follow.destX), 2.0) + math.pow((currZ - config.follow.destZ), 2.0));
		--print(dist);
		if (dist > 0.5 and dist < 30) then
			autofollowObject:runTowards(currX, currZ, config.follow.destX, config.follow.destZ);
		elseif (dist < 0.5) then
			autofollowObject.running = false;
			autofollowObject:setAutoRun(false);
			config.follow.destX = nil
			config.follow.destZ = nil
		else
			autofollowObject.running = false;
			autofollowObject:setAutoRun(false);
			print("Unable to get to path");
		end;
	end;
	
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
    	
    if (args[2] == 'cure') then
		run_cure(args);
        return true;
    end
    if (args[2] == 'cureToT') then
		run_cure_t_o_t(args);
	    return true;
    end
    if (args[2] == 'whm') then
		run_whm(args);
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
		run_pup(args);
	    return true;
    end
    if (args[2] == 'brd') then
		run_bard(args);
	    return true;
    end
    if (args[2] == 'geo') then
		run_geo(args);
	    return true;
    end
    if (args[2] == 'cor') then
		run_cor(args);
	    return true;
    end
	
	if (args[2] == 'follow') then
		config.follow.followName = args[3]
	end
	
    return true;
end);
