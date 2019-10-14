
require 'common'

addon_settings = addon_settings or { };

local function get_filename(addon_name, config_filename, user_specific)
	local playerEntity = GetPlayerEntity()
	local full_config_filename = _addon.path .. '../../config/' .. addon_name .. '/' .. config_filename .. '.json'
	if user_specific then
		full_config_filename = _addon.path .. '../../config/' .. addon_name .. '/' .. playerEntity.Name .. '_' .. config_filename .. '.json'
		if not ashita.file.file_exists(full_config_filename) then
			full_config_filename = _addon.path .. '../../config/' .. addon_name .. '/default_' .. config_filename .. '.json'
		end
	end
	return full_config_filename
end
addon_settings.get_filename = get_filename

local function onload(addon_name, config_filename, default_config_object, create_if_dne, check_for_player_entity, user_specific)

	if check_for_player_entity then
		local playerEntity = GetPlayerEntity()
		if playerEntity == nil then
			return nil;
		end
	end

	local full_config_filename = get_filename(addon_name, config_filename, user_specific)
    if (create_if_dne and not ashita.file.file_exists(full_config_filename)) then
        ashita.settings.save(full_config_filename, default_config_object);
    end

    -- Load the configuration file..
    return ashita.settings.load_merged(full_config_filename, default_config_object);
end
addon_settings.onload = onload

local function save_command (args, addon_name, config_filename, config_object, user_specific)

	if (args[2] == 'save_config') then
		local full_config_filename = get_filename(addon_name, config_filename, user_specific)
		ashita.settings.save(full_config_filename, config_object);
	end
end
addon_settings.save_command = save_command

return addon_settings