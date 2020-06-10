
_addon.name = 'warptome'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');

local crystal_warp_aliases = {
	{alias="Sih Gates", x=340.05801,y=9.3},
	{alias="Ceizak Battlegrounds", x=-238,y=0},
	{alias="Foret de Hennetiel", x=138,y=-2.465},
	{alias="Doh Gates", x=298,y=-20.866},
	{alias="Morimar Basalt Fields", x=-20,y=-47},
	{alias="Moh Gates", x=-501.094,y=39.29999},
	{alias="Marjami Ravine", x=-159.65,y=-20},
	{alias="Doh Gates", x=-258.29999,y=29.811}
}

local waypoint_aliases = {
	{alias="Courier", x=5.68499, y=0}, 
	{alias="Pioneer", x=-110.500000, y=3.850000}, 
	{alias="Mummer", x=-23.09001, y=-0.15001}, 
	{alias="Inventor", x=93.079, y=-0.15001}, 
	{alias="WestAH", x=-66.421, y=3.84999}, 
	{alias="WestMH", x=3.398000, y=0.000000}, 
	{alias="Bridge", x=174.783, y=3.84999}, 
	{alias="Docks", x=14.586000, y=0.000000}, 
	{alias="Waterfront", x=51.094, y=32}, 
	{alias="Peacekeeper", x=-101.27401, y=-0.15001}, 
	{alias="Scout", x=-76.94401, y=-0.15001}, 
	{alias="Statue", x=-46.83801, y=-0.07501}, 
	{alias="Wharf", x=-58.773, y=-0.15001}, 
	{alias="EastMH", x=-62.86501, y=-0.15001}, 
	{alias="EastAH", x=-42.065, y=-0.15001}, 
	{alias="Hillock", x=10.68099, y=-22.15}, 
	{alias="Coronal", x=26.124, y=-40.15001}, 
	{alias="Castle", x=96.994, y=-40.15001}, 
	{alias="Yahse Hunting Grounds", x=320.000000, y=0.000000}, 
	{alias="Yahse Hunting Grounds1", x=87.500000, y=0.000000}, 
	{alias="Yahse Hunting Grounds2", x=-287.500000, y=0.000000}, 
	{alias="Yahse Hunting Grounds3", x=-162.4, y=0.000000}, 
	{alias="Ceizak Battlegrounds", x=364.000000, y=0.600000}, 
	{alias="Ceizak Battlegrounds1", x=-6.87901, y=0}, 
	{alias="Ceizak Battlegrounds2", x=-42.000000, y=0.000000}, 
	{alias="Ceizak Battlegrounds3", x=-442.000000, y=0.000000}, 
	{alias="Foret de Hennetiel", x=399.10998, y=-2}, 
	{alias="Foret de Hennetiel1", x=13.600000, y=-2.400000}, 
	{alias="Foret de Hennetiel2", x=504.000000, y=-2.250000}, 
	{alias="Foret de Hennetiel3", x=103.000000, y=-2.200000}, 
	{alias="Foret de Hennetiel4", x=-251.80001, y=-2.37}, 
	{alias="Morimar Basalt Fields", x=443.72799, y=-16}, 
	{alias="Morimar Basalt Fields1", x=367.000000, y=-16.000000}, 
	{alias="Morimar Basalt Fields2", x=112.8, y=-0.48301}, 
	{alias="Morimar Basalt Fields3", x=174.500000, y=-15.581000}, 
	{alias="Morimar Basalt Fields4", x=-323.000000, y=-32.000000}, 
	{alias="Morimar Basalt Fields5", x=-78.2, y=-47.28401}, 
	{alias="Yorcia Weald", x=354.000000, y=0.200000}, 
	{alias="Yorcia Weald1", x=-39.49901, y=0.367}, 
	{alias="Yorcia Weald2", x=121.132, y=0.14599}, 
	{alias="Yorcia Weald3", x=-275.77601, y=0.35699}, 
	{alias="Marjami Ravine", x=358.000000, y=-60.000000}, 
	{alias="Marjami Ravine1", x=324.000000, y=-20.000000}, 
	{alias="Marjami Ravine2", x=6.808000, y=0.000000}, 
	{alias="Marjami Ravine3", x=-318.70801, y=-20}, 
	{alias="Marjami Ravine4", x=-326.02201, y=-40.023}, 
	{alias="Kamihr Drifts", x=439.40301, y=63}, 
	{alias="Kamihr Drifts1", x=-41.57401, y=43}, 
	{alias="Kamihr Drifts2", x=8.23999, y=43}, 
	{alias="Kamihr Drifts3", x=9.23999, y=23}, 
	{alias="Kamihr Drifts4", x=-229.94201, y=3.56699}, 
	{alias="Lower Jeuno", x=-34.92201, y=0}
}
local skirmish_aliases = {
	{alias="Rala Waterways", x=-588, y=-7.5}, 
	{alias="Cirdas Caverns", x=70.000000, y=29.296881}, 
	{alias="Yorcia WealdAG", x=170.000000, y=4.685037}, 
	{alias="Outer Ra'Kaznar", x=-148.000000, y=-170.000000}
}
local ingress_aliases = {
	{alias="1", x=-494.44001, y=-19}, 
	{alias="2", x=-404, y=-55}, 
	{alias="3", x=-531.40003, y=-50}, 
	{alias="4", x=-554.40003, y=-48.75}, 
	{alias="5", x=107, y=-75.40001}, 
	{alias="6", x=242.5, y=-87.40001}, 
	{alias="7", x=640.59997, y=-374}, 
	{alias="8", x=-368.72001, y=-113.30001}, 
	{alias="9", x=-580, y=-417.4}, 
	{alias="10", x=-389.22001, y=-439.71}
}
local zitah_eschan_portal_aliases = {
	{alias="1", x=-342, y=-0.07001}, 
	{alias="2", x=-303, y=-0.03}, 
	{alias="3", x=-261, y=0.067}, 
	{alias="4", x=-110, y=-0.11999}, 
	{alias="5", x=246, y=0.27}, 
	{alias="6", x=452, y=1.38999}, 
	{alias="7", x=192, y=0.2}, 
	{alias="8", x=-135, y=1.79999}
}
local ruaun_eschan_portal_aliases = {
	{alias="1", x=10, y=-34}, 
	{alias="2", x=-274.5, y=-40.5}, 
	{alias="3", x=-455, y=-3.5}, 
	{alias="4", x=-451.5, y=-71.42}, 
	{alias="5", x=-443.5, y=-40.5}, 
	{alias="6", x=-281.5, y=-3.5}, 
	{alias="7", x=-430.5, y=-71.85}, 
	{alias="8", x=0, y=-40.5}, 
	{alias="9", x=279.5, y=-3.63001}, 
	{alias="10", x=185, y=-71.85}, 
	{alias="11", x=443.5, y=-40}, 
	{alias="12", x=455.5, y=-3.6}, 
	{alias="13", x=545.5, y=-71.5}, 
	{alias="14", x=274, y=-40.5}, 
	{alias="15", x=-1.20001, y=-52}
}
local dimensional_portal_aliases = {
	{alias="Reisenjima", x=-500.016, y=-19.74666}, 
	{alias="Tahrongi Canyon", x=260, y=35.1506}, 
	{alias="Konschat Highlands", x=220, y=19.104}, 
	{alias="La Theine Plateau", x=420, y=19.104}
}
local undulating_confluence_aliases = {
	{alias="Quifim", x=-204.53101, y=-20.01901}, 
	{alias="Escha Zi'tah", x=-344.37201, y=1.61973}, 
	{alias="Misareaux Coast", x=-48.97701, y=-23.30917}, 
	{alias="Escha Ru'Aun", x=0.00899, y=-34.10586}
}
local unity_zones = {
	{alias="East Ronfaure"}, 
	{alias="South Gustaberg"}, 
	{alias="East Sarutabaruta"}, 
	{alias="La Theine Plateau"}, 
	{alias="Konschat Highlands"}, 
	{alias="Tahrongi Canyon"}, 
	{alias="Valkurm Dunes"}, 
	{alias="Buburimu Peninsula"} , 
	{alias="Qufim Island"}, 
	{alias="Bibiki Bay"}, 
	{alias="Carpenters' Landing"}, 
	{alias="Yuhtunga Jungle"}, 
	{alias="Lufaise Meadows"}, 
	{alias="Jugner Forest"}, 
	{alias="Pashow Marshlands"}, 
	{alias="Meriphataud Mountains"}, 
	{alias="Eastern Altepa Desert"}, 
	{alias="Yhoator Jungle"}, 
	{alias="The Sanctuary of Zi'Tah"}, 
	{alias="Misareaux Coast"}, 
	{alias="Labyrinth of Onzozo"}, 
	{alias="Bostaunieux Oubliette"}, 
	{alias="Batallia Downs"}, 
	{alias="Rolanberry Fields"}, 
	{alias="Sauromugue Champaign"}, 
	{alias="Beaucedine Glacier"}, 
	{alias="Xarcabard"}, 
	{alias="Ro'Maeve"}, 
	{alias="Western Altepa Desert"}, 
	{alias="Attowha Chasm"}, 
	{alias="Garliage Citadel"}, 
	{alias="Ifrit's Cauldron"}, 
	{alias="The Boyhada Tree"}, 
	{alias="Kuftal Tunnel"}, 
	{alias="Sea Serpent Grotto"}, 
	{alias="Temple of Uggalepih"}, 
	{alias="Quicksand Caves"}, 
	{alias="Wajaom Woodlands"}, 
	{alias="Lufaise Meadows"}, 
	{alias="Cape Terrigan"}, 
	{alias="Den of Rancor"}, 
	{alias="Fei'Yin"}, 
	{alias="Alzadaal Undersea Ruins"}, 
	{alias="Misareaux Coast"}, 
	{alias="Mount Zhayolm"}, 
	{alias="Gustav Tunnel"}, 
	{alias="Behemoth's Dominion"}, 
	{alias="The Boyhada Tree"}, 
	{alias="Valley of Sorrows"}, 
	{alias="Wajaom Woodlands"}, 
	{alias="Mount Zhayolm"}, 
	{alias="Caedarva Mire"}
}


local function homepoint_warp(zone, test_mode)
	local result = nil;
	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0 and math.sqrt(e.Distance) < 6 and result == nil) then
				
			if string.find(e.Name, 'Home Point') then
				result = {};
				result['Alias'] = zone
				result['Type'] = 'hp'
			
				if string.find(e.Name,'2') then 
					result['Alias'] = zone .. '2'
				elseif string.find(e.Name,'3') then 
					result['Alias'] = zone .. '3'
				elseif string.find(e.Name,'4') then 
					result['Alias'] = zone .. '4'
				elseif string.find(e.Name,'5') then
					result['Alias'] = zone .. '5'
				end
			end;
		end
	end

	return result
end

local function survival_guide_warp(zone, test_mode)

	local result = nil;
	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0 and math.sqrt(e.Distance) < 6 and result == nil) then
			if string.find(e.Name, 'Survival Guide') then
				result = {};
				result['Alias'] = zone
				result['Type'] = 'sg'
			end;
		end
	end

	return result	
end

local function lookup_by_location(zone, entity_name, aliases, type_text, test_mode) 
	local result = nil;
	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0 and math.sqrt(e.Distance) < 6 and result == nil) then
			if string.find(e.Name, entity_name) then
				local waypointx = math.floor(e.Movement.LocalPosition.X * 100000)/100000
				local waypointy = math.floor(e.Movement.LocalPosition.Y * 100000)/100000
				for i,j in ipairs(aliases) do
					if(waypointx == j.x) then
						result = {};
						result['Alias'] = j.alias 
						result['Type'] = type_text
					end
				end
				if result == nil and test_mode then
					print('\30\110'..type_text..' not found in aliases: '..e.Name);
					print('\30\110'..type_text..' not found in aliases: '..waypointx);
					print('\30\110'..type_text..' not found in aliases: '..waypointy);						
				end
			end;
		end
	end

	return result
end

local function waypoint_warp(zone)
	return lookup_by_location(zone, 'Waypoint', waypoint_aliases, 'wp', test_mode)
end

local function augural_conveyor(zone)
	return lookup_by_location(zone, 'Augural Conveyor', skirmish_aliases, 'wp', test_mode)
end

local function crystal_warp(zone)
	return lookup_by_location(zone, '???', crystal_warp_aliases, 'cw', test_mode)
end

local function escha_zone_warp(zone, test_mode)
	local result = lookup_by_location(zone, 'Dimensional Portal', dimensional_portal_aliases, 'ee', test_mode)
	if result == nil then
		result = lookup_by_location(zone, 'Undulating Confluence', undulating_confluence_aliases, 'ee', test_mode)
	end
	return result
end

local function escha_di_warp(zone, test_mode)
	local has_elvorseal = false
	local status_list = AshitaCore:GetDataManager():GetPlayer():GetStatusIcons();
    for slot = 0, 31, 1 do
		--print(status_list[slot])
		if status_list[slot] == 603 then
			has_elvorseal = true
		end
    end
	local result = nil  
	if has_elvorseal then
		result = {};
		result['Alias'] = zone 
		result['Type'] = 'ev'
	end
	--602 or 603
	return result
end

local function escha_portal_warp(zone, test_mode)
	local result = lookup_by_location(zone, 'Ethereal Ingress', ingress_aliases, 'ep', test_mode)
	if result == nil then
		result = lookup_by_location(zone, 'Eschan Portal', zitah_eschan_portal_aliases, 'ep', test_mode)
	end
	if result == nil then
		result = lookup_by_location(zone, 'Eschan Portal', ruaun_eschan_portal_aliases, 'ep', test_mode)
	end
	return result
end

local function unity_warp(zone, test_mode)
	local result = nil
	for i,j in ipairs(unity_zones) do
		if(zone == j.alias) then
			result = {};
			result['Alias'] = j.alias 
			result['Type'] = 'uc'
		end
	end
	return result
end

local function find_warp(test_mode)
    local party     = AshitaCore:GetDataManager():GetParty();
	local zone = AshitaCore:GetResourceManager():GetString('areas', party:GetMemberZone(0))
	
	local result = homepoint_warp(zone, test_mode)
	if result == nil then
		result = survival_guide_warp(zone, test_mode)
	end
	if result == nil then
		result = augural_conveyor(zone, test_mode)
	end
	if result == nil then
		result = waypoint_warp(zone, test_mode)
	end
	if result == nil then
		result = crystal_warp(zone, test_mode)
		if result ~= nil then
			result['Alias'] = ''
		end
	end
	if result == nil then
		result = escha_portal_warp(zone, test_mode)
	end
	if result == nil then
		result = escha_zone_warp(zone, test_mode)
		if result ~= nil then
			result['Alias'] = ''
		end
	end
	if result == nil then
		result = escha_di_warp(zone, test_mode)
		if result ~= nil then
			result['Alias'] = ''
		end
	end
	if result == nil then
		result = unity_warp(zone, test_mode)
	end

	return result	
end

local function handle_command(command, nType)
	local args = command:args();
    local cmd = args[2];
	local user = args[3]
	if (#args >=2 and args[1] == '/warptome') then
		
		local result = find_warp(false)
		if result ~= nil then
			local qCommand = '/ms sendto ' .. user .. ' /uw ' .. result['Type'] .. result['Alias']
			--print("\30\68\ " .. qCommand)
			AshitaCore:GetChatManager():QueueCommand(qCommand, 1)
		end
		return true;
	elseif (#args >=1 and args[1] == '/warptometest') then	
		
		local result = find_warp(true)
		if result ~= nil then
			local qCommand = '/ms sendto [user] /uw ' .. result['Type'] .. result['Alias']
			print("\30\68\ " .. qCommand)
		end
		
	end
	return false;
end

ashita.register_event('command', handle_command);