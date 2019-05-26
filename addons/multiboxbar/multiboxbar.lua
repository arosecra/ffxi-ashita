
_addon.author   = 'arosecra';
_addon.name     = 'multiboxbar';
_addon.version  = '1.0.0';

require 'common'
local jobs = require 'windower/res/jobs'

----------------------------------------------------------------------------------------------------
-- Default Configurations
----------------------------------------------------------------------------------------------------
local default_config =
{
};

local modes = {
	"Actions", "Buffs", "Settings", "Items"
};

local hotbar_variables = {
	['Mode'] = "Settings"
}

local hotbar_config = default_config;
local function msg(s)
    local txt = '\31\200[\31\05Multiboxbar\31\200]\31\130 ' .. s;
    print(txt);
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Save the default settings if they don't exist..
    if (not ashita.file.file_exists(_addon.path .. '../../config/multiboxbar/multiboxbar.json')) then
        ashita.settings.save(_addon.path .. '../../config/multiboxbar/multiboxbar.json', hotbar_config);
    end

    -- Load the configuration file..
    hotbar_config = ashita.settings.load_merged(_addon.path .. '../../config/multiboxbar/multiboxbar.json', hotbar_config);
end);


ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/multiboxbar' and args[1] ~= '/mbb') then
        return false;
    end
	
	local player = AshitaCore:GetDataManager():GetPlayer();
    if (player == nil) then
        return false;
    end
	
	local playerEntity = GetPlayerEntity();
    if (playerEntity == nil) then
        return;
    end
        
    -- Skip invalid commands..
    if (#args <= 1) then
        return true;
    end
    
    -- Do we want to add a trigger..
    if (args[2] == 'list') then
		for k,v in pairs(hotbar_variables) do
			msg(k .. ': ' .. v)
		end
        return true;
    end
	
	
    return true;
end);

--ashita.register_event('key', function(key, down, blocked)
--	
--	if key == 29 then
--		msg('blocking')
--		return true;
--	else
--		if down then
--			msg('key event ' .. key .. ' down')
--		else
--			msg('key event ' .. key .. ' up')
--		end
--	end
--    return false;
--end);

function display_macro_button(hotbar_user, macro, hotbar_variables)
	local result = false
	local playerEntity = GetPlayerEntity()
    local player = AshitaCore:GetDataManager():GetPlayer();
	local party  = AshitaCore:GetDataManager():GetParty();
	
	if hotbar_user.Static == true then
		result = true
	elseif macro.Conditions ~= nil then
		result = true
		for k,v in pairs(macro.Conditions) do
			if hotbar_variables[k] ~= nil and hotbar_variables[k] ~= v then
				result = false
				break
			end
		end
	end
	
	return result
end


ashita.register_event('prerender', function()

	hotbar_variables = {
		['Mode'] = hotbar_variables['Mode']
	}
	
    local player = AshitaCore:GetDataManager():GetPlayer();
	local party  = AshitaCore:GetDataManager():GetParty();
	local playerEntity = GetPlayerEntity()
    if (player == nil or playerEntity == nil or party == nil) then
        return;
    end
	
	hotbar_variables[playerEntity.Name .. '.MainJob'] = jobs[player:GetMainJob()].en
	hotbar_variables[playerEntity.Name .. '.SubJob'] = jobs[player:GetSubJob()].en
	
	local party  = AshitaCore:GetDataManager():GetParty();
	for i=1,5 do
		local name = AshitaCore:GetDataManager():GetParty():GetMemberName(i)
		local mainjob = AshitaCore:GetDataManager():GetParty():GetMemberMainJob(i)
		local subjob  = AshitaCore:GetDataManager():GetParty():GetMemberSubJob(i)
		hotbar_variables[name .. '.MainJob'] = jobs[mainjob].en
		hotbar_variables[name .. '.SubJob'] = jobs[subjob].en
	end
	
	for hotbar_user_id,hotbar_user in pairs(hotbar_config) do
		if player == hotbar_user.Name then
			hotbar_variables[hotbar_user.Name .. '.Engaged'] = (player.status == 1)
		end
	end
end);


ashita.register_event('render', function()
    -- Obtain the local player..
    
    -- Display the pet information..
    imgui.SetNextWindowSize(800, 215, ImGuiSetCond_Always);
    if (imgui.Begin('multiboxbar') == false) then
        imgui.End();
        return;
    end
	for index,mode in ipairs(modes) do
		if imgui.SmallButton(mode) then
			hotbar_variables['Mode'] = mode
		end
		imgui.SameLine()
	end
	
	imgui.Separator();
	
	for hotbar_user_id,hotbar_user in pairs(hotbar_config) do
		imgui.Text(hotbar_user.Name);
		local user_buttons = 0
		for hotbar_macro_index,hotbar_macro in ipairs(hotbar_user.Macros) do
			if display_macro_button(hotbar_user, hotbar_macro, hotbar_variables) then
				local label = hotbar_macro.Name
				if #label > 12 then
					label = string.sub(label,1,10) .. '..'
				end
				user_buttons = user_buttons+1
				if (imgui.SmallButton(label)) then 
					if hotbar_macro.Script then
						msg(hotbar_macro.Script)
						AshitaCore:GetChatManager():QueueCommand('/exec "' .. hotbar_macro.Script, 1)
					elseif hotbar_macro.Command then
						msg(hotbar_macro.Command)
						AshitaCore:GetChatManager():QueueCommand(hotbar_macro.Command, 1)
					end
				end
				if user_buttons % 8 == 0 then
					imgui.Separator();
				else
					imgui.SameLine();
				end
			end
		end		
		
		imgui.Separator();
	end

    imgui.End();
end);