
_addon.author   = 'arosecra';
_addon.name     = 'multiboxbar';
_addon.version  = '1.0.0';

require 'common'
require 'stringex'
local jobs = require 'windower/res/jobs'

----------------------------------------------------------------------------------------------------
-- Default Configurations
----------------------------------------------------------------------------------------------------
local default_config =
{
};

local modes = {
	"Sttngs1",
	"Sttngs2",
	"Actns1",
	"Actns2", 
	"Actns3", 
	"WS", 
	"Buff",  
	"Item",
};

--my keyboard doesn't seem to reliably send some keycodes
--along with the numpad keys. this is a work around for this situation

local ALT     = 56;
local WIN     = 219;
local CONTROL = 29;
local MENU    = 221;
local control_key_states = {
	[ALT]     = false,
	[WIN]     = false,
	[CONTROL] = false,
	[MENU]    = false,
}

local hotbar_variables = {
	['Mode'] = "Sttngs1"
}

local hotbar_config = default_config;
local function msg(s)
    local txt = '\31\200[\31\05Multiboxbar\31\200]\31\130 ' .. s;
    print(txt);
end

local current_hotbar = {
}

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
	
	
    if (args[2] == 'button_from_controller') then
	
		--determine the mode, since we can't rely on keybinds entirely (stupid keyboard?)
		local section = get_current_macro_row_number()
		if section == 0 then
			run_set_mode_command(tonumber(args[3]))	
		else
			run_macro_command(section, tonumber(args[3]))	
		end
        return true;
    end
    if (args[2] == 'setmode') then
		run_set_mode_command(tonumber(args[3]))
        return true;
    end
    if (args[2] == 'runmacro') then --[mbb|multiboxbar] run #sectionNumber #macroNumber
		run_macro_command(tonumber(args[3]), tonumber(args[4]))
        return true;
    end
	
    return true;
end);

function run_macro_command(section_number, macro_number) 
	local current_section = current_hotbar[section_number]
	if current_section ~= nil then
		local macro = current_section[macro_number]
		if macro ~= nil then
			run_macro(macro)
		end
	end
end

function run_set_mode_command(mode_number) 
	for k,v in ipairs(modes) do
		if k == mode_number then
			hotbar_variables['Mode'] = v
		end
	end
end

ashita.register_event('key', function(key, down, blocked)
    
	--msg('key event ' .. key)
	if key == ALT or key == WIN or key == CONTROL or key == MENU then
		if down then
			--print("key down " .. key)
			control_key_states[key] = true
		else
			--print("key up " .. key)
			control_key_states[key] = false
		end
	end
    return false;
end);


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

function display_macro_section(conditions, hotbar_variables)
	local result = false
	local playerEntity = GetPlayerEntity()
    local player = AshitaCore:GetDataManager():GetPlayer();
	local party  = AshitaCore:GetDataManager():GetParty();
	
	if conditions.Static == true then
		result = true
	elseif conditions ~= nil then
		result = true
		for k,v in pairs(conditions) do
			if hotbar_variables[k] ~= nil and hotbar_variables[k] ~= v then
				result = false
				break
			end
		end
	end
	
	return result
end

function get_active_macros(hotbar_section, hotbar_variables) 
	local result = {}
	for conditions_id,conditions in ipairs(hotbar_section.Conditions) do
		if display_macro_section(conditions, hotbar_variables) then
			result = conditions.Macros;
			break;
		end
	end
	return result
end

function run_macro(hotbar_macro) 
	if hotbar_macro.Script then
		msg(hotbar_macro.Script)
		AshitaCore:GetChatManager():QueueCommand('/exec "' .. hotbar_macro.Script, 1)
	elseif hotbar_macro.Command then
		msg(hotbar_macro.Command)
		AshitaCore:GetChatManager():QueueCommand(hotbar_macro.Command, 1)
	end
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

function get_current_macro_row_number()
	local section = 0
	if      control_key_states[ALT]     == true and
	        control_key_states[WIN]     == false and
	        control_key_states[CONTROL] == false and
	        control_key_states[MENU]    == false then
		section = 1;
	elseif control_key_states[ALT]     == false and
	        control_key_states[WIN]     == true and
	        control_key_states[CONTROL] == false and
	        control_key_states[MENU]    == false then
		section = 2;
	elseif control_key_states[ALT]     == false and
	        control_key_states[WIN]     == false and
	        control_key_states[CONTROL] == true and
	        control_key_states[MENU]    == false then
		section = 3
	elseif control_key_states[ALT]     == false and
	        control_key_states[WIN]     == false and
	        control_key_states[CONTROL] == false and
	        control_key_states[MENU]    == true then
		section = 4	
	end
	return section
end

function get_button_label_text(original_label, size)
	return original_label .. string.rep(' ', size - #original_label)
end

ashita.register_event('render', function()
    -- Obtain the local player..
    
    -- Display the pet information..
    imgui.SetNextWindowSize(680, 125, ImGuiSetCond_Always);
    if (imgui.Begin('multiboxbar') == false) then
        imgui.End();
        return;
    end
	
	
	imgui.Text(get_button_label_text(hotbar_variables['Mode'] , 8));
	imgui.SameLine();
	
	imgui.Text("            L         U         D         R");
	imgui.SameLine();
	imgui.Text("        X         Y         A         B");
	
	imgui.Text(get_button_label_text("Pages", 16));
	imgui.SameLine();
	
	for index,mode in ipairs(modes) do
		local modeDisplay = mode .. string.rep(' ', 8 - #mode)
		--print(mode .. ' ' .. modeLength .. ' ' .. padlength .. ' ' .. modeDisplay)
		if imgui.SmallButton(modeDisplay) then
			hotbar_variables['Mode'] = mode
		end
		imgui.SameLine()
	end
	
	imgui.Separator();
	
	local section = get_current_macro_row_number()
	for hotbar_section_id,hotbar_section in ipairs(hotbar_config) do
		local sectionName = hotbar_section.Name
		if hotbar_section_id == section then
			sectionName = "(*) " .. sectionName .. string.rep(' ', 12 - #sectionName)
		else 
			sectionName = "( ) " .. sectionName .. string.rep(' ', 12 - #sectionName)
		end
		imgui.Text(sectionName);
		imgui.SameLine();
		local macros = get_active_macros(hotbar_section, hotbar_variables)
		
		current_hotbar[hotbar_section_id] = macros;
		
		for i=1,8 do
			local label = string.rep(' ', 8)
			if macros ~= nil and #macros >= i then
				label = macros[i].Name
				if #label > 12 then
					label = string.sub(label,1,8) .. '..'
				else
					label = label .. string.rep(' ', 8 - #label)
				end
			end
			
			if (imgui.SmallButton(label)) then 
				if macros ~= nil and #macros >= i then
					local hotbar_macro = macros[i]
					run_macro(hotbar_macro)
				end
			end	
			imgui.SameLine();			
		end
				
		imgui.Separator();
	end

    imgui.End();
end);