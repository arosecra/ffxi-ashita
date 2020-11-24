

local jobs = require 'windower/res/jobs'
local nuke = {}
nuke.spell_metadata = {
	["stormI"] = { Index = 1, Target = "<me>" },
	["stormII"]= { Index= 2, Target = "<me>" },
	["helixI"]= { Index= 3, Target = "<t>" },
	["helixII"]= { Index= 4, Target = "<t>" },
	["nukeI"]= { Index= 5, Target = "<t>" },
	["nukeII"]= { Index= 6, Target = "<t>" },
	["nukeIII"]= { Index= 7, Target = "<t>" },
	["nukeIV"]= { Index= 8, Target = "<t>" },
	["nukeV"]= { Index= 9, Target = "<t>" }
};

nuke.spells = {
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

function nuke:init_config(config)
	config.nuke = {
		element = "fire"
	}
end

function nuke:command(config, args)
	if (args[3] == 'setelement') then
		config.nuke.element = args[4]
	else
		nuke:run_nuke(config, args[3])
	end
end

function nuke:render(config)

end

function nuke:run_nuke(config, spellType, target)
	if nuke.spell_metadata[spellType] ~= nil then
		local spellIndex = nuke.spell_metadata[spellType].Index
		local spell = nuke.spells[config.nuke.element][spellIndex]
		local spellTarget = nuke.spell_metadata[spellType].Target
		local command = "/ma \"" .. spell .. "\" " .. spellTarget 
		--print(command)
		run_command(command)
	end
end



return nuke