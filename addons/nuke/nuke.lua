
_addon.name = 'nuke'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');

local element = "Fire"

local spell_metadata = {
	["stormI"] = {
		Index = 1,
		Target = "<me>"
	},
	["stormII"]= {
		Index= 2,
		Target = "<me>"
	},
	["helixI"]= {
		Index= 3,
		Target = "<t>"
	},
	["helixII"]= {
		Index= 4,
		Target = "<t>"
	},
	["nukeI"]= {
		Index= 5,
		Target = "<t>"
	},
	["nukeII"]= {
		Index= 6,
		Target = "<t>"
	},
	["nukeIII"]= {
		Index= 7,
		Target = "<t>"
	},
	["nukeIV"]= {
		Index= 8,
		Target = "<t>"
	},
	["nukeV"]= {
		Index= 9,
		Target = "<t>"
	}
};

local spells = {
	["fire"]= 
	{
		"Firestorm", "Firestorm II", 
		"Pyrohelix", "Pyrohelix II", 
		"Fire", "Fire II", "Fire III", "Fire IV", "Fire V"
	},
	["stone"]= {
		"Sandstorm", "Sandstorm II",
		"Geohelix", "Geohelix II",
		"Stone", "Stone II", "Stone III", "Stone IV", "Stone V"
	},
	["water"]= {
		"Rainstorm", "Rainstorm II",
		"Hydrohelix", "Hydrohelix II",
		"Water", "Water II", "Water III", "Water IV", "Water V"
	},
	["wind"]= {
		"Windstorm", "Windstorm II",
		"Anemohelix", "Anemohelix II",
		"Aero", "Aero II", "Aero III", "Aero IV", "Aero V"
	},
	["ice"]= {
		"Hailstorm", "Hailstorm II",
		"Cryohelix", "Cryohelix II",
		"Blizzard", "Blizzard II", "Blizzard III", "Blizzard IV", "Blizzard V"
	},
	["thunder"]= {
		"Thunderstorm", "Thunderstorm II",
		"Ionohelix", "Ionohelix II",
		"Thunder", "Thunder II", "Thunder III", "Thunder IV", "Thunder V"
	},
	["light"]= {
		"Aurorastorm", "Aurorastorm II",
		"Luminohelix", "Luminohelix II"
	},
	["dark"]= {
		"Voidstorm", "Voidstorm II",
		"Noctohelix", "Noctohelix II"
	}
};

local function handle_command(command, nType)
	local args = command:args();
	if (#args ==3 and args[1] == '/nuke' and args[2] == 'setelement') then
		element = args[3]
		print('\31\200[\31\05Nuke\31\200]\31\130 Element changed to ' .. element)
	elseif (#args ==2 and args[1] == '/nuke') then
		--print(args[1] .. ' ' .. args[2])
		
		local spellType = args[2]
		if spell_metadata[spellType] ~= nil then
			local spellIndex = spell_metadata[spellType].Index
			local spell = spells[element][spellIndex]
			local spellTarget = spell_metadata[spellType].Target
			local command = "/ma \"" .. spell .. "\" " .. spellTarget 
			--print(command)
			AshitaCore:GetChatManager():QueueCommand(command, 1)
		end
		return true;
		
	end
	return false;
end

ashita.register_event('command', handle_command);