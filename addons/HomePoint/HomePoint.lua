--[[

Copyright © 2016, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of HomePoint nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'HomePoint'

_addon.author = 'Sammeh'

_addon.version = '1.0.8'


-- 1.0.2 - fixed if you mistyped one
-- 1.0.3 - fixed up some naming of home points in map
-- 1.0.4 - fix bug when not in a zone with a HP
-- 1.0.5 - fix homepoint name of Marjami Ravine to "Marjami Ravine 1"
-- 1.0.6 - Added a reset option - which will reset a locked NPC transaction.
-- 1.0.7 - Added //hp set  to set HomePoint to closest hp.
-- 1.0.8 - Adding some data validation to help prevent locked NPC transactions.

-- Usage  //hp warp <Location> <# of HomePoint>   
-- Examples:  //hp warp Mhaura 1
--			  //hp warp Ru'Aun Gardens 5


-- Converted to Ashita addon by shinzaru

require('common');
db = require ('map');

npc_name = ""


pkt = {}

found = 0
hpset = 0

defaults = {}

--settings = config.load(defaults)

busy = false

ashita.register_event('command', function(command, nType)
    local args = command:args();
    local cmd = args[2];
	if (#args >=2 and args[1] == '/hp') then
		table.remove(args, 1);
		table.remove(args, 1);
		
		for i,v in pairs(args) do args[i] = ParseAutoTranslate(args[i], false) end
		local item = table.concat(args," "):lower();
		if cmd == 'warp' then
			hpset = 0;
			local validatehp = fetch_db(item);
			local findhp = find_homepoint();
			if findhp == 1 then 
				if validatehp then
					print("\30\110\Warping to: "..item);
					if not busy then
						pkt = validate(item)
						if pkt then
							busy = true
							poke_npc(pkt['Target'],pkt['Target Index']);
						end
					end
				else 
					print("\30\110\Could not find Home Point: "..item);
				end;
			end;
		elseif cmd == 'test' then
			hpset = 0;
			test = 1;
			if not busy then
				pkt = validate(item);
				if pkt then
					busy = true;
					poke_npc(pkt['Target'],pkt['Target Index']);
				end;
			end;
		elseif cmd == 'set' then
			hpset = 1;
			local findhp = find_homepoint();
			local validatehp = fetch_db(item);
			if findhp == 1 then
				if not busy then
					pkt = validate(item);
					if pkt then
						busy = true;
						poke_npc(pkt['Target'],pkt['Target Index']);
					end;
				end;
			end;
		elseif cmd == 'reset' then
			reset_me();
		else
			print("\30\68\No Home Point found.  Are you near one?");
		end;
		
		return true;
	end;
	
	return false;
end)


function validate(item)

	local zone = AshitaCore:GetDataManager():GetParty():GetMemberZone(0);

	local me,target_index,target_id,distance,found;
	

	local result = {};
	
	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0) then
			if (e.Name == GetPlayerEntity().Name) then
				results['me'] = i;
			elseif string.find(e.Name, 'Home Point') then
				found = 1;
				target_index = e.TargetIndex;
				target_id = e.ServerId;
				npc_name = e.Name;
				
				if string.find(npc_name,'1') then 
					result['Menu ID'] = 8700
				elseif string.find(npc_name,'2') then 
					result['Menu ID'] = 8701
				elseif string.find(npc_name,'3') then 
					result['Menu ID'] = 8702
				elseif string.find(npc_name,'4') then 
					result['Menu ID'] = 8703
				elseif string.find(npc_name,'5') then 
					result['Menu ID'] = 8704
				end
				
				distance = e.Distance;
				print('\30\110Found: '..npc_name..' Distance: '..math.sqrt(distance));
				if math.sqrt(distance)<6 then break end
			end;
		end
	end

	if found == 1 then 
	
	if math.sqrt(distance)<6 then
		local ite = fetch_db(item)
		
		if ite then
			result['Target'] = target_id
			result['Option Index'] = ite['Option']
			result['_unknown1'] = ite['Index']
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
		if test == 1 then
			result['Target'] = target_id
			result['Option Index'] = 2
			result['_unknown1'] = item
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
		if hpset == 1 then
			result['Target'] = target_id
			result['Option Index'] = 8
			result['_unknown1'] = 0
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
	else
		print("\30\68\Found Home Point - but too far! Get within 6 yalms");
		result = nil;
	end
	
	else 	  
		print("\30\68\"No Home Point Found");
	end
	return result;

end


function fetch_db(item)
 for i,v in pairs(db) do
  if string.lower(i) == string.lower(item) then
	return v
  end
 end
end


ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
	if id == 0x032 or id == 0x034 then
		if (id == 0x032) then
			pMenuID = struct.unpack('H', packet, 0x00C + 1);
		else
			pMenuID = struct.unpack('H', packet, 0x02C + 1);
		end;
		
		if busy == true and pkt then
			if (pMenuID >= 8700 and pMenuID <= 8704) then
				if hpset == 1 then
					hpset = 0;
					-- build packet
					local packet = struct.pack('bbbbihhhbbhh', 0x05B, 0x05, 0x00, 0x00, pkt['Target'], 8, 0, pkt['Target Index'], 1, 0, pkt['Zone'], pMenuID):totable();
					AddOutgoingPacket(0x05B, packet);
					
					packet = struct.pack('bbbbihhhbbhh', 0x05B, 0x05, 0x00, 0x00, pkt['Target'], 1, 0, pkt['Target Index'], 0, 0, pkt['Zone'], pMenuID):totable();
					AddOutgoingPacket(0x05B, packet);
				else
					-- request warp
					local packet = struct.pack('bbbbihhhbbhh', 0x05B, 0x05, 0x00, 0x00, pkt['Target'], 8, 0, pkt['Target Index'], 1, 0, pkt['Zone'], pMenuID):totable();
					AddOutgoingPacket(0x05B, packet);
					
					packet = struct.pack('bbbbihhhbbhh', 0x05B, 0x05, 0x00, 0x00, pkt['Target'], pkt['Option Index'], pkt['_unknown1'], pkt['Target Index'], 1, 0, pkt['Zone'], pMenuID):totable();
					AddOutgoingPacket(0x05B, packet);
		
					-- send exit menu
					packet = struct.pack('bbbbihhhbbhh', 0x05B, 0x05, 0x00, 0x00, pkt['Target'], pkt['Option Index'], pkt['_unknown1'], pkt['Target Index'], 0, 0, pkt['Zone'], pMenuID):totable();
					AddOutgoingPacket(0x05B, packet);					
				end;
				
				busy = false;
				pkt = {};
				return true;
			else
				busy = false
				print("\30\110\Packet Inspection for HP Did not return Proper Menu - Exiting");
			end;
		end;
	end;
	
	return false;
end);



function poke_npc(npc,target_index)
	if npc and target_index then
		local pokeNpcPacket = struct.pack('bbbbihhhhfff', 0x01A, 0x07, 0, 0, npc, target_index, 0, 0, 0, 0, 0, 0):totable();			
		AddOutgoingPacket(0x01A, pokeNpcPacket);
	end
end


function find_homepoint()
	found = 0;
	for x = 0, 2303 do
		local e = GetEntity(x);
		if (e ~= nil and e.WarpPointer ~= 0) then
			if string.find(e.Name, 'Home Point') then
				found = 1;
				target_index = e.TargetIndex;
				target_id = e.ServerId;
				npc_name = e.Name;
				distance = e.Distance;
			end;
		end;
	end;
	return found;
end

function reset_me()
	-- Void; Erased by Sammeh
end;

ashita.register_event('load', function()
end)




