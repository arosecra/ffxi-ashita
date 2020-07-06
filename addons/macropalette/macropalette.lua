
_addon.author   = 'arosecra';
_addon.name     = 'macropalette';
_addon.version  = '1.0.0';

require 'common'
require 'stringex'
local jobs = require 'windower/res/jobs'
local addon_settings = require 'addon_settings'

----------------------------------------------------------------------------------------------------
-- Default Configurations
----------------------------------------------------------------------------------------------------

local modes = {
	"Sttngs1",
	"Sttngs2",
	"Actns1",
	"Actns2", 
	"Actns3", 
	"WS", 
	"Buff",  
	"Item"
};

--my keyboard doesn't seem to reliably send some keycodes (to lua?)
--along with the numpad keys. this is a work around for this situation

--left control	29
--right control	157
--left win		219
--left shift	42
--right shift	54
--right alt		184
--left alt		56
--menu			221
--
--numpad 0		82
--numpad 1		79
--numpad 2		80
--numpad 3		81
--numpad 4		75
--numpad 5		76
--numpad 6		77
--numpad 7		71
--numpad 8		72
--numpad 9		73

local LEFT_ALT		= 56 ;
local RIGHT_ALT		= 184;
local WIN			= 219;
local LEFT_CONTROL	= 29 ;
local RIGHT_CONTROL	= 157;
local MENU			= 221;
local LEFT_SHIFT	= 42 ;
local RIGHT_SHIFT	= 54 ;

local NUMPAD_0		= 82 ;
local NUMPAD_1		= 79 ;
local NUMPAD_2		= 80 ;
local NUMPAD_3		= 81 ;
local NUMPAD_4		= 75 ;
local NUMPAD_5		= 76 ;
local NUMPAD_6		= 77 ;
local NUMPAD_7		= 71 ;
local NUMPAD_8		= 72 ;
local NUMPAD_9		= 73 ;


local control_key_states = {
	[LEFT_ALT]		 = false,
	[RIGHT_ALT]		 = false,
	[WIN]			 = false,
	[LEFT_CONTROL]	 = false,
	[RIGHT_CONTROL]	 = false,
	[MENU]			 = false,
	[LEFT_SHIFT]	 = false,
	[RIGHT_SHIFT]	 = false,
}
local control_key_sections = {
	[LEFT_ALT]		 = 4,
	[RIGHT_ALT]		 = 5,
	[WIN]			 = 3,
	[LEFT_CONTROL]	 = 2,
	[RIGHT_CONTROL]	 = 7,
	[MENU]			 = 6,
	[LEFT_SHIFT]	 = 1,
	[RIGHT_SHIFT]	 = 8,
}

local hotbar_variables = {
	['Mode'] = "Sttngs1"
}

local hotbar_config = {};
local hotbar_position_config = {};
local function msg(s)
    local txt = '\31\200[\31\05MacroPalette\31\200]\31\130 ' .. s;
    print(txt);
end

local current_hotbar = {
}
local last_player_entity = nil

local HEIGHT = 0;
local WIDTH = 0;
local NUMBER_OF_BUTTONS = 8

local debug_loop_count = 0

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
	--addon_settings.onload(addon_name, config_filename, default_config_object, create_if_dne, check_for_player_entity, user_specific)
	hotbar_config = addon_settings.onload(_addon.name, _addon.name, {}, true, false, false)
	
	HEIGHT = ((1+#hotbar_config.Palette)*20)+5
	WIDTH = (NUMBER_OF_BUTTONS +1) * 72 + 5
end);

ashita.register_event('command', function(cmd, nType)
    -- Skip commands that we should not handle..
    local args = cmd:args();
    if (args[1] ~= '/macropalette' and args[1] ~= '/mp') then
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
	
	if (args[2] == 'debug_conditions') then
		local section = args[3]
		local index = tonumber(args[4])
		for hotbar_section_id,hotbar_section in ipairs(hotbar_config) do
			if hotbar_section.Name == section then
				for conditions_id,conditions in ipairs(hotbar_section.Conditions) do
					if index == conditions_id then
						result = display_macro_section(conditions, hotbar_variables, true);
						break;
					end
				end
			end
		end
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
	
	if (args[2] == 'validate_macro_names') then
		
		
		
		for hotbar_section_id,hotbar_section in ipairs(hotbar_config.Palette) do
			local macro_names = get_active_macro_names(hotbar_section, hotbar_variables)	
			
			for i=1,NUMBER_OF_BUTTONS do
				if macro_names[i] ~= nil then
					if hotbar_config.Macros[macro_names[i]] == nil then
						print(hotbar_section.Name .. "." .. macro_names[i] .. ' is not defined')
					else
						print(hotbar_section.Name .. "." .. macro_names[i] .. ' is defined')
					end
				end
		end
			
		end
	end
	
	--addon_settings.save_command (args, _addon.name, 'imgui', hotbar_position_config, true);
	
    return true;
end);

function run_macro_command(section_number, macro_number) 
	print('attempting to run macro ' .. section_number .. ' ' .. macro_number)
	local current_section = current_hotbar[section_number]
	if current_section ~= nil then
		local macro = current_section[macro_number]
		if macro ~= nil then
			run_macro(hotbar_config.Palette[section_number], macro, "commandline")
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
	if key == LEFT_ALT or 
		key == RIGHT_ALT or
		key == LEFT_CONTROL or 
		key == RIGHT_CONTROL or
		key == LEFT_SHIFT or
		key == RIGHT_SHIFT or
		key == WIN or 
		key == MENU
	then
		if down then
			--print("key down " .. key)
			control_key_states[key] = true
		else
			--print("key up " .. key)
			control_key_states[key] = false
		end
		return true;
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

function display_macro_section(conditions, hotbar_variables, debug_mode)
	local result = false
	
	if conditions.Static == true then
		if debug_mode then
			msg('Condition is static')
		end
		result = true
	elseif conditions ~= nil then
		result = true
		local found = true
		for k,v in pairs(conditions) do
			if k ~= 'Macros' then
				if debug_mode then
					msg('Searching for Condition '..k)
				end
				if hotbar_variables[k] ~= nil then
					found = true
					if debug_mode then
						msg('Condition '..k..' found, value is '..hotbar_variables[k])
					end
					if hotbar_variables[k] ~= v then
						result = false
						if debug_mode then
							msg('Condition '..k..' value did not match expected '..v)
						end
					end
				else
					if debug_mode then
						msg('Condition '..k..' not found in table')
					end
					found = false
					break
				end
			end
		end
		
		if not found then
			result = false
		end
	end
	
	if debug_mode and result then
		msg('result is true')
	end
	if debug_mode and not result then
		msg('result is false')
	end
	return result
end

function get_active_macro_names(hotbar_section, hotbar_variables)
	local macro_names = {}
	for palette_row_id,palette_row in ipairs(hotbar_section.Modes) do
			
		if palette_row.Mode == hotbar_variables['Mode'] then
			for i=1,NUMBER_OF_BUTTONS do
				if palette_row.Macros[i] ~= nil 
					and palette_row.Macros[i] ~= "" 
					and palette_row.Macros[i] ~= "job"  then
					--if it is in the top section, it is static
					macro_names[i] = palette_row.Macros[i]
				else
					--check if there is a job specific macro here
					local job = hotbar_variables[hotbar_section.Name .. '.MainJob']
					local job_macros = hotbar_config.JobMacros[job]
					
					
					if job_macros ~= nil then
						for job_row_id, job_row in ipairs(job_macros) do
						
							if job_row.Mode == hotbar_variables['Mode'] then
								if job_row.Macros[i] ~= nil 
									and job_row.Macros[i] ~= "" 
									and job_row.Macros[i] ~= "job"  then
									--if it is in the top section, it is static
									macro_names[i] = job_row.Macros[i]
								end
							end
						end
					end
				end
			end			
		
			break;
		end
	
	end
	return macro_names;
end

function get_active_macros(hotbar_section, hotbar_variables) 
	local result = {}
	local macro_names = get_active_macro_names(hotbar_section, hotbar_variables)	
	
	for i=1,NUMBER_OF_BUTTONS do
		if macro_names[i] ~= nil then
			if hotbar_config.Macros[macro_names[i]] ~= nil then
				result[i] = hotbar_config.Macros[macro_names[i]]
			else
				result[i] = {
					Spacer=true
				}
			end
		else
			result[i] = {
				Spacer=true
			}
		end
	end
	
	--once we know macro names, pull the details from the macro section
	
	return result
end

function run_macro(section, hotbar_macro, mode)
	if hotbar_macro.Script then
		msg(hotbar_macro.Script)
		AshitaCore:GetChatManager():QueueCommand('/exec "' .. hotbar_macro.Script, 1)
	elseif hotbar_macro.Command then
		msg(hotbar_macro.Command)
		AshitaCore:GetChatManager():QueueCommand(hotbar_macro.Command, 2)
	elseif hotbar_macro.SendTo then
		msg('/ms sendto ' .. section.Name .. ' ' .. hotbar_macro.SendTo)
		AshitaCore:GetChatManager():QueueCommand('/ms sendto ' .. section.Name .. ' ' .. hotbar_macro.SendTo, 2)
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
		last_player_entity = nil	
		hotbar_position_config = {};
        return;
    end
	if last_player_entity == nil then
		--addon_settings.onload(addon_name, config_filename, default_config_object, create_if_dne, check_for_player_entity, user_specific)
		hotbar_position_config = addon_settings.onload(_addon.name, 'imgui', {}, true, true, true)
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
	for i,j in pairs(control_key_states) do 
		if j then
			section = control_key_sections[i]
			break
		end
	end
	return section
end

function get_button_label_text(original_label, size)
	return original_label .. string.rep(' ', size - #original_label)
end

ashita.register_event('render', function()
    -- Obtain the local player..
	if hotbar_position_config[1] == nil then
		return;
	end
	
	local playerEntity = GetPlayerEntity()
    if (playerEntity == nil) then
        return;
    end
	
	--if (imgui.Begin('settings', true) == false) then
    --    imgui.End();
    --    return;
    --end
	--
	--imgui.Checkbox('MP+', false)
    --
	--
	--imgui.End()
	
	
    -- Display the macro bar 
	imgui.SetNextWindowPos(hotbar_position_config[1], hotbar_position_config[2]);
    imgui.SetNextWindowSize(WIDTH, HEIGHT, ImGuiSetCond_Always);
	local window_flags = 0
	window_flags = bit.bor(window_flags, ImGuiWindowFlags_NoTitleBar)
	window_flags = bit.bor(window_flags, ImGuiWindowFlags_NoCollapse)
	window_flags = bit.bor(window_flags, ImGuiWindowFlags_NoSavedSettings)
    if (imgui.Begin('macropalette', true, window_flags) == false) then
        imgui.End();
        return;
    end
	
	imgui.Text(get_button_label_text("Pages", 12));
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
	
	imgui.Text(get_button_label_text(hotbar_variables['Mode'] , 8));
	imgui.SameLine();
	
	imgui.Text("        L         U         D         R");
	imgui.SameLine();
	imgui.Text("        X         Y         A         B");
	--imgui.SameLine();
	--imgui.Text("        BK        ST");
	
	local section = get_current_macro_row_number()
	for hotbar_section_id,hotbar_section in ipairs(hotbar_config.Palette) do
		local sectionName = hotbar_section.Name
		if hotbar_section_id == section then
			sectionName = "(*) " .. sectionName .. string.rep(' ', 8 - #sectionName)
		else 
			sectionName = "( ) " .. sectionName .. string.rep(' ', 8 - #sectionName)
		end
		imgui.Text(sectionName);
		imgui.SameLine();
		local macros = get_active_macros(hotbar_section, hotbar_variables)
		
		current_hotbar[hotbar_section_id] = macros;
		
		for i=1,NUMBER_OF_BUTTONS do
			local label = string.rep(' ', 8)
			if macros ~= nil and #macros >= i and macros[i].Spacer == nil then
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
					run_macro(hotbar_section, hotbar_macro, "click")
				end
			end	
			imgui.SameLine();			
		end
				
		imgui.Separator();
	end

    imgui.End();
end);