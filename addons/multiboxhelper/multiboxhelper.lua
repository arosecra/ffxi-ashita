
_addon.author   = 'arosecra';
_addon.name     = 'multiboxhelper';
_addon.version  = '1.0.0';

require 'common'
require 'stringex'
local jobs = require 'windower/res/jobs'
--local addon_settings = require 'addon_settings'

local config = {
	brd = {
		songs = {}
	},
	cor = {
		rolls = {}
	},
	geo = {
	}
};

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
	
end);

local function run_cure(args)
	local lowestHpp = 100;
	local lowestHp = 0;
	local lowestName;
	local hpMissing = 0;
	for i=0,5 do
		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
		local hp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(i)
		local hpp = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(i)
		if (name ~= "") then
			if (hpp < lowestHpp) then
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
	
		if hpMissing > 500 then
			AshitaCore:GetChatManager():QueueCommand("/ma \"Cure IV\" " .. lowestName, 1)
		else
			AshitaCore:GetChatManager():QueueCommand("/ma \"Cure III\" " .. lowestName, 1)
		end
	end

end

local function run_cure_t_o_t(args)
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
		AshitaCore:GetChatManager():QueueCommand("/ma \"" .. config.brd.songs[args[4]] .. "\" <me>", 1)
	end
end

local function run_geo(args)
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

-- mbh cure
-- mbh cureToT
-- mbh brd setsong [n] [song name]
-- mbh brd singsong [n]
-- mbh brd singdummysong [n]
-- mbh cor setroll [n] [roll name]
-- mbh cor roll [n]
-- mbh geo setbubble [spell name]
-- mbh geo setluopan [spell name]
-- mbh geo setentrust [spell name]
-- mbh geo bubble
-- mbh geo entrust
-- mbh geo luopan
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
    if (args[2] == 'bard') then
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
	
    return true;
end);

--ashita.register_event('prerender', function()
--
--	hotbar_variables = {
--		['Mode'] = hotbar_variables['Mode']
--	}
--	
--    local player = AshitaCore:GetDataManager():GetPlayer();
--	local party  = AshitaCore:GetDataManager():GetParty();
--	local playerEntity = GetPlayerEntity()
--    if (player == nil or playerEntity == nil or party == nil) then
--		last_player_entity = nil	
--		hotbar_position_config = {};
--        return;
--    end
--	if last_player_entity == nil then
--		--addon_settings.onload(addon_name, config_filename, default_config_object, create_if_dne, check_for_player_entity, user_specific)
--		hotbar_position_config = addon_settings.onload(_addon.name, 'imgui', {}, true, true, true)
--	end
--	
--	hotbar_variables[playerEntity.Name .. '.MainJob'] = jobs[player:GetMainJob()].en
--	hotbar_variables[playerEntity.Name .. '.SubJob'] = jobs[player:GetSubJob()].en
--	
--	local party  = AshitaCore:GetDataManager():GetParty();
--	for i=1,5 do
--		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
--		local mainjob = AshitaCore:GetDataManager():GetParty():GetMemberMainJob(i)
--		local subjob  = AshitaCore:GetDataManager():GetParty():GetMemberSubJob(i)
--		hotbar_variables[name .. '.MainJob'] = jobs[mainjob].en
--		hotbar_variables[name .. '.SubJob'] = jobs[subjob].en
--	end
--	
--	for hotbar_user_id,hotbar_user in pairs(hotbar_config) do
--		if player == hotbar_user.Name then
--			hotbar_variables[hotbar_user.Name .. '.Engaged'] = (player.status == 1)
--		end
--	end
--	
--end);
