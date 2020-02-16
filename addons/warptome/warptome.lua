
_addon.name = 'warptome'
_addon.author = 'arosecra'
_addon.version = '1.0.0'

require('common');

local waypoints = {
	{alias="Courier", x=5.685000, y=0.000000}, 
	{alias="Pioneer", x=-110.500000, y=3.850000}, 
	{alias="Mummer", x=-23.090000, y=-0.150000}, 
	{alias="Inventor", x=93.079002, y=-0.150000}, 
	{alias="WestAH", x=-66.420998, y=3.850000}, 
	{alias="WestMH", x=3.398000, y=0.000000}, 
	{alias="Bridge", x=174.783005, y=3.850000}, 
	{alias="Docks", x=14.586000, y=0.000000}, 
	{alias="Waterfront", x=51.094002, y=32.000000}, 
	{alias="Peacekeeper", x=-101.274002, y=-0.150000}, 
	{alias="Scout", x=-76.944000, y=-0.150000}, 
	{alias="Statue", x=-46.838001, y=-0.075000}, 
	{alias="Wharf", x=-58.772999, y=-0.150000}, 
	{alias="EastMH", x=-62.865002, y=-0.150000}, 
	{alias="EastAH", x=-42.064999, y=-0.150000}, 
	{alias="Hillock", x=10.681000, y=-22.150000}, 
	{alias="Coronal", x=26.124001, y=-40.150002}, 
	{alias="Castle", x=96.994003, y=-40.150002}, 
	{alias="Yahse Hunting Grounds", x=320.000000, y=0.000000}, 
	{alias="Yahse Hunting Grounds1", x=87.500000, y=0.000000}, 
	{alias="Yahse Hunting Grounds2", x=-287.500000, y=0.000000}, 
	{alias="Yahse Hunting Grounds3", x=-162.399994, y=0.000000}, 
	{alias="Ceizak Battlegrounds", x=364.000000, y=0.600000}, 
	{alias="Ceizak Battlegrounds1", x=-6.879000, y=0.000000}, 
	{alias="Ceizak Battlegrounds2", x=-42.000000, y=0.000000}, 
	{alias="Ceizak Battlegrounds3", x=-442.000000, y=0.000000}, 
	{alias="Foret de Hennetiel", x=399.109985, y=-2.000000}, 
	{alias="Foret de Hennetiel1", x=13.600000, y=-2.400000}, 
	{alias="Foret de Hennetiel2", x=504.000000, y=-2.250000}, 
	{alias="Foret de Hennetiel3", x=103.000000, y=-2.200000}, 
	{alias="Foret de Hennetiel4", x=-251.800003, y=-2.370000}, 
	{alias="Morimar Basalt Fields", x=443.727997, y=-16.000000}, 
	{alias="Morimar Basalt Fields1", x=367.000000, y=-16.000000}, 
	{alias="Morimar Basalt Fields2", x=112.800003, y=-0.483000}, 
	{alias="Morimar Basalt Fields3", x=174.500000, y=-15.581000}, 
	{alias="Morimar Basalt Fields4", x=-323.000000, y=-32.000000}, 
	{alias="Morimar Basalt Fields5", x=-78.199997, y=-47.284000}, 
	{alias="Yorcia Weald", x=354.000000, y=0.200000}, 
	{alias="Yorcia Weald1", x=-39.499001, y=0.367000}, 
	{alias="Yorcia Weald2", x=121.132004, y=0.146000}, 
	{alias="Yorcia Weald3", x=-275.776001, y=0.357000}, 
	{alias="Marjami Ravine", x=358.000000, y=-60.000000}, 
	{alias="Marjami Ravine1", x=324.000000, y=-20.000000}, 
	{alias="Marjami Ravine2", x=6.808000, y=0.000000}, 
	{alias="Marjami Ravine3", x=-318.708008, y=-20.000000}, 
	{alias="Marjami Ravine4", x=-326.022003, y=-40.022999}, 
	{alias="Kamihr Drifts", x=439.403015, y=63.000000}, 
	{alias="Kamihr Drifts1", x=-41.574001, y=43.000000}, 
	{alias="Kamihr Drifts2", x=8.240000, y=43.000000}, 
	{alias="Kamihr Drifts3", x=9.240000, y=23.000000}, 
	{alias="Kamihr Drifts4", x=-229.942001, y=3.567000}, 
	{alias="Lower Jeuno", x=-34.922001, y=0.000000}, 
	{alias="Rala Waterways", x=-588.000000, y=-7.500000}, 
	{alias="Cirdas Caverns", x=70.000000, y=29.296881}, 
	{alias="Yorcia Weald", x=170.000000, y=4.685037}, 
	{alias="Outer Ra'Kaznar", x=-148.000000, y=-170.000000}
}

local function find_warp()
    local party     = AshitaCore:GetDataManager():GetParty();
	local player	= AshitaCore:GetDataManager():GetPlayer();
	local target    = AshitaCore:GetDataManager():GetTarget();
	local zone = AshitaCore:GetResourceManager():GetString('areas', party:GetMemberZone(0))
	
	local distance,found,warp_point_type,alias;

	local result = {};

	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0) then
			distance = math.sqrt(e.Distance)
			if (distance < 6) then
				if string.find(e.Name, 'Survival Guide') then
					found = 1;
					alias = zone;
					warp_point_type = 'sg'
					
				elseif string.find(e.Name, 'Home Point') then
					found = 1;
					alias = zone
					warp_point_type = 'hp'
				
					if string.find(e.Name,'2') then 
						alias = zone .. '2'
					elseif string.find(e.Name,'3') then 
						alias = zone .. '3'
					elseif string.find(e.Name,'4') then 
						alias = zone .. '4'
					elseif string.find(e.Name,'5') then
						alias = zone .. '5'
					end
				elseif string.find(e.Name, 'Waypoint') then
					local waypointx = math.floor(e.Movement.LocalPosition.X * 1000000)/1000000
					for i,j in ipairs(waypoints) do
						if(waypointx == j.x) then
							warp_point_type = 'wp'
							found = 1
							alias = j.alias
						end
					end
				end;
			end
		end
	end

	if found == 1 then 
		print('\30\110Found: '..alias..' Distance: '..distance);
	
		if math.sqrt(distance)<6 then
			result['Alias'] = alias 
			result['Type'] = warp_point_type
		else
			print("\30\68\Found warp point - but too far! Get within 6 yalms")
			result = nil
		end
	
	else 
		print("\30\68\No warp point Found")
	end
	return result	
end

local function handle_command(command, nType)
	local args = command:args();
    local cmd = args[2];
	local user = args[3]
	if (#args >=2 and args[1] == '/warptome') then
		
		local result = find_warp()
		local qCommand = '/ms sendto ' .. user .. ' /uw ' .. result['Type'] .. result['Alias']
		--print("\30\68\ " .. qCommand)
		AshitaCore:GetChatManager():QueueCommand(qCommand, 1)
		
		return true;
	elseif (#args >=1 and args[1] == '/warptometest') then	
		for x = 0, 2303 do
			local e = GetEntity(x);
			if (e ~= nil and e.WarpPointer ~= 0) then
				if string.find(e.Name, 'Waypoint') then
					found = 1;
					npc_name = e.Name;
					warp_point_type = 'Waypoint'
					
					distance = e.Distance;
					print('\30\110Found: '..npc_name..' Distance: '..math.sqrt(distance));
					print('\30\110Found: '..e.Movement.LocalPosition.X);
					print('\30\110Found: '..e.Movement.LocalPosition.Y);
					
					local waypointx = math.floor(e.Movement.LocalPosition.X * 1000000)/1000000
					for i,j in pairs(waypoints) do
						print('\30\110attempt to match' .. j.x .. ' ' .. waypointx)
						if(waypointx == j.x) then
							print('\30\110X matched')
						end
					end
					
					if math.sqrt(distance)<6 then break end
				end
			end
		end
	end
	return false;
end

ashita.register_event('command', handle_command);