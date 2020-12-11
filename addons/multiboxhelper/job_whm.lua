

local whm = {}
whm.statuses = {
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


function whm:init_config(config)
	config.whm = {
	}
end

-- 11/22/2020
-- cure i     - 107    215
-- cure ii    - 226    403
-- cure iii   - 514    812
-- cure iv    - 959   1313
-- cure v     - 1182  1595
-- cure vi    - 1513  1944
-- curega i   - 169    293
-- curega ii  - 346    520
-- curega iii - 700    893 
-- curega iv  - 1255  1599
-- curega v   - 1637  2325
function whm:command(config, args)
	if (args[3] == 'cure') then
		whm:run_cure(100, 250, 400, 800, 1000, 1300, args)
	elseif (args[3] == 'curega') then
		whm:run_curega(100, 250, 500, 600, args)
	elseif (args[3] == 'cure_t_o_t') then
		whm:run_cure_t_o_t(args)
	elseif (args[3] == 'removedebuff') then
		whm:run_remove_debuff(config, args)
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

function whm:render(config)
end

function whm:run_cure(cure1, cure2, cure3, cure4, cure5, cure6, args)
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
	
	if lowestHpp < 100 then
		start_action()
		local command = ""
		if hpMissing > cure6 then
			command = "/ma \"Cure VI\" " .. lowestName
		elseif hpMissing > cure5 then
			command = "/ma \"Cure V\" " .. lowestName
		elseif hpMissing > cure4 then
			command = "/ma \"Cure IV\" " .. lowestName
		elseif hpMissing > cure3 then
			command = "/ma \"Cure III\" " .. lowestName
		elseif hpMissing > cure2 then
			command = "/ma \"Cure II\" " .. lowestName
		elseif hpMissing > cure1 then
			command = "/ma \"Cure\" " .. lowestName
		end
		
		run_command(command)
	end

end

function whm:run_curega(cure1, cure2, cure3, cure4, args)
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
			command = "/ma \"Curaga IV\" " .. lowestName
		elseif hpMissing > cure3 then
			command = "/ma \"Curaga III\" " .. lowestName
		elseif hpMissing > cure2 then
			command = "/ma \"Curaga II\" " .. lowestName
		elseif hpMissing > cure1 then
			command = "/ma \"Curaga\" " .. lowestName
		end
		
		run_command(command)
	end

end

function whm:run_remove_debuff(config, args)

	for istatus,status in ipairs(whm.statuses) do
		
		for i=0,4 do
			if config.party_status_effects[i] ~= nil then
			
				for j=0,31 do
					if config.party_status_effects[i].Statuses[j] ~= nil and config.party_status_effects[i].Statuses[j].StatusName == status.name then
						start_action()
						AshitaCore:GetChatManager():QueueCommand("/ma \"" .. status.spell .. "\" " .. config.party_status_effects[i].Name, 1)
						break;
					end
				end
			end
		end
	
	end


end

return whm