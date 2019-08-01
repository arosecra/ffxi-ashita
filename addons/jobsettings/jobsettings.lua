
_addon.name = 'jobsettings'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');
local jobs = require 'windower/res/jobs'

local settings = {

}

local function handle_command(command, nType)
	local args = command:args();
	if (#args ==2 and args[1] == '/jobsettings') then
	
	
	
		local player = AshitaCore:GetDataManager():GetPlayer();
		local mainJob = jobs[player:GetMainJob()].en
		
		if (not ashita.file.file_exists(_addon.path .. '../../config/jobsettings/' .. mainJob .. '.json')) then
			ashita.settings.save(_addon.path .. '../../config/jobsettings/' .. mainJob .. '.json', {});
		end
		local jobsettings = ashita.settings.load_merged(_addon.path .. '../../config/jobsettings/' .. mainJob .. '.json', {});
		
		local setting = args[2]
		if settings[mainJob] == nil then
			settings[mainJob] = {}
		end
		local mainJobSettings = settings[mainJob]
		if mainJobSettings[setting] == nil then
			mainJobSettings[setting] = 1
		end
		
		local newIndex = mainJobSettings[setting] + 1
		if jobsettings[setting] ~= nil then
			if #jobsettings[setting] < newIndex then
				newIndex = 1
			end
			mainJobSettings[setting] = newIndex
			local settingValue = jobsettings[setting][newIndex]
			
			if settingValue.Value ~= nil then
				local command = "/ac var set " .. setting .. " " .. settingValue.Value
				AshitaCore:GetChatManager():QueueCommand(command, 1)
				print('Setting ' .. setting .. ' to ' .. settingValue.Value)
			else 
				print('Setting ' .. setting .. ' to ' .. settingValue.Name)
				for k,v in ipairs(settingValue.Settings) do
					local command = "/ac var set " .. v.Name .. " " .. v.Value
					AshitaCore:GetChatManager():QueueCommand(command, 1)
				end
			end
		end
	end
	return false;
end

ashita.register_event('command', handle_command);