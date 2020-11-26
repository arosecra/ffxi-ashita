

require 'common'
local sch = {}

sch.skillchains = {
["liq_f"]   = { DisplayName = "Liquefaction",  MB = "Fire",           Spells = { [1] = "Stone",       Wait = 3,  [2] = "Fire"}},
["sci_s"]   = { DisplayName = "Scission",      MB = "Stone",          Spells = { [1] = "Fire",        Wait = 3,  [2] = "Stone"}},
["rev_w"]   = { DisplayName = "Reverberation", MB = "Water",          Spells = { [1] = "Stone",       Wait = 3,  [2] = "Water"}},
["det_a"]   = { DisplayName = "Detonation",    MB = "Aero",           Spells = { [1] = "Stone",       Wait = 3,  [2] = "Aero"}},
["ind_b"]   = { DisplayName = "Induration",    MB = "Blizzard",       Spells = { [1] = "Water",       Wait = 3,  [2] = "Blizzard"}},
["imp_t"]   = { DisplayName = "Impaction",     MB = "Thunder",        Spells = { [1] = "Blizzard",    Wait = 3,  [2] = "Thunder"}},
["trns_l"]  = { DisplayName = "Transfixion",   MB = "Light",          Spells = { [1] = "Noctohelix",  Wait = 5,  [2] = "Luminohelix"}},
["com_d"]   = { DisplayName = "Compression",   MB = "Dark",           Spells = { [1] = "Blizzard",    Wait = 3,  [2] = "Noctohelix"}},
["frag_at"] = { DisplayName = "Fragmentation", MB = "Aero/Thunder",   Spells = { [1] = "Blizzard",    Wait = 3,  [2] = "Water"}},
["fus_fl"]  = { DisplayName = "Fusion",        MB = "Fire/Light",     Spells = { [1] = "Fire",        Wait = 3,  [2] = "Thunder"}},
["grav_ds"] = { DisplayName = "Gravitation",   MB = "Earth/Dark",     Spells = { [1] = "Aero",        Wait = 3,  [2] = "Noctohelix"}},
["dist_wb"] = { DisplayName = "Distortion",    MB = "Water/Blizzard", Spells = { [1] = "Luminohelix", Wait = 5,  [2] = "Stone"}}
}

function sch:init_config(config)
	config.sch = {}
end

function sch:command(config, args)
	if (args[3] == 'setslfsc') then
		config.sch['slfsc'] = args[4]
		msg("Set skillchain to " .. args[4])
	elseif (args[3] == 'slfsc') then
		ashita.timer.once(1, step1, sch.skillchains[config.sch.slfsc])
	end
end

function step1(skillchain_info) 
	run_command("/p (Starting Gear) (Skillchain) (" .. skillchain_info.DisplayName .. ") MB: (" .. skillchain_info.MB .. ")", 1)
	ashita.timer.once(1, step2, skillchain_info)
end

function step2(skillchain_info) 
	run_command("/ja Immanence <me>")
	ashita.timer.once(2, step3, skillchain_info)
end

function step3(skillchain_info) 
	run_command("/ma " .. skillchain_info.Spells[1] .. " <t>")
	ashita.timer.once(skillchain_info.Spells.Wait, step4, skillchain_info)
end

function step4(skillchain_info) 
	run_command("/p (Closed Position) (Skillchain in 3)", 1)
	ashita.timer.once(1, step5, skillchain_info)
end

function step5(skillchain_info) 
	run_command("/ja Immanence <me>")
	ashita.timer.once(2, step6, skillchain_info)
end

function step6(skillchain_info) 
	run_command("/ma " .. skillchain_info.Spells[2] .. " <t>")
end



return sch