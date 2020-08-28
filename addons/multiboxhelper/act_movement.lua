

require 'autofollow'
local autofollowObject = autoFollow;

local movement = {}






function movement:init_config(config)
	config.movement = {
		destX = nil,
		destZ = nil,
		followName = nil,
		following = nil,
		inAction = false
	}
	
	autofollowObject.baseAddress = ashita.memory.read_int32(ashita.memory.find("FFXiMain.dll", 0, "F6C4447A42D905????????D81D????????", 7, 0)); 
	if (autofollowObject.baseAddress) then
		-- Do nothing; Addon was able to load
	else
		print("Unable to find autofollow pointer");
		chatManager:QueueCommand("/addon unload " .. _addon.name, 1);
	end;
end

function movement:command(config, args)
end

function movement:render(config)
	local currX = AshitaCore:GetDataManager():GetEntity():GetLocalX(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(0));
	local currZ = AshitaCore:GetDataManager():GetEntity():GetLocalZ(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(0));
	
	if  (os.time() >= (autofollowObject.timer + autofollowObject.delay)) then
        autofollowObject.timer = os.time();
	end;
	
	if not autofollowObject.running and 
	   config.movement.destX ~= nil and 
	   config.movement.destZ ~= nil and
	   not config.movement.inAction then
		autofollowObject:setAutoRun(true)
		autofollowObject.running = true;
	end

	-- Has to be ran faster than timing loop
	if (autofollowObject.running) then		
		local dist = math.sqrt(math.pow((currX - config.movement.destX), 2.0) + math.pow((currZ - config.movement.destZ), 2.0));
		--print(dist);
		if (dist > 0.5 and dist < 30) then
			autofollowObject:runTowards(currX, currZ, config.movement.destX, config.movement.destZ);
		elseif (dist < 0.5) then
			autofollowObject.running = false;
			autofollowObject:setAutoRun(false);
			config.movement.destX = nil
			config.movement.destZ = nil
		else
			autofollowObject.running = false;
			autofollowObject:setAutoRun(false);
			print("Unable to get to path");
		end;
	end;
end

return movement