debugging = false
logged_in = GetPlayerEntity() ~= nil

local _lua_require = require

local _windower_libs = {
    ['actions']   = 1,
    ['chat']      = 1,
    ['chat/colors']   = 1,
    ['chat/controls'] = 1,
    ['config']    = 1,
    ['files']     = 1,
    ['functions'] = 1,
    ['images']    = 1,
    ['json']      = 1,
    ['lists']     = 1,
    ['logger']    = 1,
    ['maths']     = 1,
    ['pack']      = 1,
    ['resources'] = 1,
    ['sets']      = 1,
    ['strings']   = 1,
    ['tables']    = 1,
    ['texts']     = 1,
    ['xml']       = 1,
}

require = function(module)
    if _windower_libs[module] == 1 then
        local success, result = pcall(_lua_require, 'windower.' .. module)
        if success then return result end

        print('error loading windower module ' .. module);
        print('  > ' .. result)
    end
    return _lua_require(module)
end

function dump(o)
    if type(o) == 'userdata' then
        return dump(getmetatable(o))
    end
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

----------------------------------------------------------------------------------------------------
-- func: switch
-- desc: Switch case implementation for Lua. (Credits: Unknown Original Author)
----------------------------------------------------------------------------------------------------
function switch(c)
    local switch_table = 
    {
        casevar = c,
        caseof = function(self, code)
            local f;
            if (self.casevar) then
                f = code[self.casevar] or code.default;
            else
                f = code.missing or code.default;
            end
            if f then
                if (type(f) == 'function') then
                    return f(self.casevar,self);
                else
                    error('case: ' .. tostring(self.casevar) .. ' is not a function!');
                end
            end
        end
    };
    return switch_table
end

windower = windower or {}

windower.wc_match = function(str, pattern)
end

require 'ffxi.targets'
require 'mathex'
require 'pack'
require 'strings'
require 'tables'
require 'timer'

coroutine.close = function(co)
end

coroutine.schedule = function(fn, time)
    local co = coroutine.create(fn)
    ashita.timer.once(time, coroutine.resume, co)
    return co
end

coroutine.sleep = function(time)
    local co = coroutine.running()
    ashita.timer.once(time, coroutine.resume, co)
    coroutine.yield()
end

windower.windower_path = _addon.path .. 'windower/'
windower.addon_path = _addon.path

windower.dump = dump

windower.debug = function(string)
    if debugging then
        print('DEBUG: ' .. string)
    end
end

windower.error = function(string)
    print('ERROR: ' .. string)
end

local DEL1, DEL2 = string.byte("'", 1), string.byte('"', 1)
local split_addon_args = function(str)
    local result = T{}
    local delimiter = nil
    local b = 1
    for i = 1, #str do
        local c = string.byte(str, i)
        if not delimiter then
            if c == DEL1 or c == DEL2 then
                local subs = string.psplit(string.spaces_collapse(string.trim(string.sub(str, b, i - 1))), ' ')
                table.extend(result, subs)
                delimiter = c
                b = i + 1
            end
        else
            if c == delimiter then
                table.insert(result, string.sub(str, b, i - 1))
                delimiter = nil
                b = i + 1
            end
        end
        if i == #str and i > b then
            if not delimiter then
                local subs = string.psplit(string.spaces_collapse(string.trim(string.sub(str, b, i))), ' ')
                table.extend(result, subs)
            else
                table.insert(result, string.sub(str, b, i))
            end
        end
    end
--    print(dump(result))
    return unpack(result)
end

EVENT_LOAD      = 'load'
EVENT_LOGIN     = 'login'
EVENT_LOGOUT    = 'logout'
EVENT_PRERENDER = 'prerender'
EVENT_ADDON_CMD = 'addon command'
EVENT_INC_TEXT  = 'incoming text'
EVENT_INC_CHUNK = 'incoming chunk'
EVENT_OUT_CHUNK = 'outgoing chunk'

local handlers_by_event = {}
local handlers_by_id = {}

windower.register_event = function(...)
    local args = {...}
    if #args < 2 then
        return
    end

    local handler = args[#args]

    table.insert(handlers_by_id, handler)

    local id = table.find(handlers_by_id, functions.equals(handler))

    for i = 1, #args - 1 do
        local event = args[i]
--        print('REGISTER EVENT: ' .. event .. ' ' .. tostring(handler))
        handlers_by_event[event] = handlers_by_event[event] or {}
        table.insert(handlers_by_event[event], handler)

        if event == EVENT_LOAD and #handlers_by_event[EVENT_LOAD] == 1 then
            ashita.register_event('load', function()
                for _, handler in pairs(handlers_by_event[EVENT_LOAD]) do
                    handler()
                end
            end)
        end

        if event == EVENT_LOGIN and #handlers_by_event[EVENT_LOGIN] == 1 then
            local next_sequence = nil
            windower.register_event(EVENT_INC_CHUNK, function (id,original,modified,is_injected,is_blocked)
                local seq = original:unpack("H", 0x03)
                if (next_sequence and seq >= next_sequence) then
                    logged_in = true
                    for _, handler in pairs(handlers_by_event[EVENT_LOGIN]) do
--                        print('Logging in...')
                        handler(GetPlayerEntity().Name)
                    end
                    next_sequence = nil
                end
                if id == 0x0A and not logged_in then
                    next_sequence = (seq + 10) % 0x10000
                end
            end)
        end

        if event == EVENT_LOGOUT and #handlers_by_event[EVENT_LOGOUT] == 1 then
            windower.register_event(EVENT_OUT_CHUNK, function(id, packet, packet_modified, injected, blocked)
                if id == 0xE7 then
                    logged_in = false
                    for _, handler in pairs(handlers_by_event[EVENT_LOGOUT]) do
--                        print('Logging out...')
                        handler(GetPlayerEntity().Name)
                    end
                end
            end)
        end

        if event == EVENT_PRERENDER and #handlers_by_event[EVENT_PRERENDER] == 1 then
            ashita.register_event('prerender', function()
                for _, handler in pairs(handlers_by_event[EVENT_PRERENDER]) do
                    handler()
                end
            end)
        end

        if event == EVENT_ADDON_CMD and #handlers_by_event[EVENT_ADDON_CMD] == 1 then
            ashita.register_event('command', function(cmd, nType)
                local prefix, args = string.match(cmd, '^/([^%s]+)(.*)')
                if _addon.command and _addon.command ~= prefix then
                    return false
                end
                if _addon.commands and not table.contains(_addon.commands, prefix) then
                    return false
                end

                for _, handler in pairs(handlers_by_event[EVENT_ADDON_CMD]) do
                    handler( split_addon_args(string.trim(args)) )
                end
                return true
            end)
        end

        if event == EVENT_INC_TEXT and #handlers_by_event[EVENT_INC_TEXT] == 1 then
            ashita.register_event('incoming_text', function(mode, message, mode_mod, message_mod, blocked)
                local is_blocked = blocked
                local is_modified_mode = false
                local is_modified_msg  = false
                local mode_new = mode_mod
                local msg_new = message_mod
                if msg_new == '' then
                    msg_new = message
                end
                for _, handler in pairs(handlers_by_event[EVENT_INC_TEXT]) do
                    local r1, r2 = handler(message, msg_new, mode, mode_new, is_blocked)
                    if r1 ~= nil then
                        if type(r1) == 'boolean' then
                            is_blocked = is_blocked or r1
                        end
                        if type(r1) == 'string' then
                            is_modified_msg = true
                            msg_new = r1
                            if r2 ~= nil and type(r2) == 'number' then
                                is_modified_mode = true
                                mode_new = r2
                            end
                        end
                        if type(r1) == 'number' then
                            is_modified_mode = true
                            mode_new = r1
                            if r2 ~= nil and type(r2) == 'string' then
                                is_modified_msg = true
                                msg_new = r2
                            end
                        end
                    end
                end
                if is_blocked then
--                    print('block text .. ' .. message)
                    return is_blocked
                end
                if is_modified_mode or is_modified_msg then
--                    print('modify text .. mode(' .. tostring(mode) .. ',' .. tostring(mode_new) .. ')')
--                    print('modify text .. text(' .. message .. ',' .. msg_new .. ')')
                    return msg_new, mode_new
                end
                return false
            end)
        end

        if event == EVENT_INC_CHUNK and #handlers_by_event[EVENT_INC_CHUNK] == 1 then
            ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
                local is_blocked = blocked or false
                local is_modified = false
                local m = packet_modified or packet
                for _, handler in pairs(handlers_by_event[EVENT_INC_CHUNK]) do
                    local result = handler(id, packet, m, false, is_blocked)
                    if result ~= nil then
                        if type(result) == 'string' then
                            is_modified = true
                            m = result
                        end
                        if type(result) == 'boolean' then
                            is_blocked = is_blocked or result
                        end
                    end
                end
                if is_blocked then
                    return is_blocked
                end
                if is_modified then
--                    print('modify packet ... id=' .. tostring(id))
                    return {string.byte(m, 1, size)}
                end
                return false
            end)
        end

        if event == EVENT_OUT_CHUNK and #handlers_by_event[EVENT_OUT_CHUNK] == 1 then
            ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
                local is_blocked = blocked or false
                local is_modified = false
                local m = packet_modified or packet
                for _, handler in pairs(handlers_by_event[EVENT_OUT_CHUNK]) do
                    local result = handler(id, packet, m, false, is_blocked)
                    if result ~= nil then
                        if type(result) == 'string' then
                            is_modified = true
                            m = result
                        end
                        if type(result) == 'boolean' then
                            is_blocked = is_blocked or result
                        end
                    end
                end
                if is_blocked then
                    return is_blocked
                end
                if is_modified then
--                    print('modify packet ... id=' .. tostring(id))
                    return {string.byte(m, 1, size)}
                end
                return false
            end)
        end
    end

    return id
end

windower.unregister_event = function(...)
    local args = {...}
    for i = 1, #args do
        local id, handler = table.find(handlers_by_id, args[i])
        if id ~= nil and handler ~= nil then
            for event, handlers in pairs(handlers_by_event) do
                table.delete(handlers, handler)
            end
            table.delete(handlers_by_id, handler)
        end
    end
end

local change_handlers = {
    ['status'] = function() return GetPlayerEntity().Status end,
    ['hp']      = function() return AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0) end,
    ['mp']      = function() return AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0) end,
    ['tp']      = function() return AshitaCore:GetDataManager():GetParty():GetMemberCurrentTP(0) end,
    ['hpp']     = function() return AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(0) end,
    ['mpp']     = function() return AshitaCore:GetDataManager():GetParty():GetMemberCurrentMPP(0) end,
    ['zone']    = function() return windower.ffxi.get_info().zone end,
    ['weather'] = function() return ashita.ffxi.weather.get_weather() end,
    ['job']     = function() return ashita.ffxi.weather.get_weather() end,
    ['time']    = function() return ashita.ffxi.vanatime.get_current_time() end,
    ['moon']    = function() return ashita.ffxi.vanatime.get_current_date().moon_phase end,
}
local current_change_values = {}

local handle_change_events = function()
    for name, value_fn in pairs(change_handlers) do
        local event = name .. ' change'
        if handlers_by_event[event] and #handlers_by_event[event] > 0 then
            local old = current_change_values[name]
            local new = value_fn()
            if old ~= new then
                for _, handler in pairs(handlers_by_event[event]) do
                    handler(new, old)
                end
                current_change_values[name] = new
            end
        end
    end
end

windower.register_event(EVENT_OUT_CHUNK, function(id, packet, packet_modified, injected, blocked)
    if id == 0x15 then
--        print('Handling status changes')
        handle_change_events()
    end
end)

windower.get_windower_settings = function()
    local res = {}
    res['x_res'] = AshitaCore:GetConfigurationManager():get_int32('boot_config', 'window_x', 800)
    res['y_res'] = AshitaCore:GetConfigurationManager():get_int32('boot_config', 'window_y', 800)
    res['ui_x_res'] = AshitaCore:GetConfigurationManager():get_int32('boot_config', 'menu_x', 0)
    res['ui_y_res'] = AshitaCore:GetConfigurationManager():get_int32('boot_config', 'menu_y', 0)
--    launcher_version: number  
--    window_x_pos: int  
--    window_y_pos: int  
    return res
end

local execute_lua_command = function(cmd)
    local sub, addon, params = string.match(cmd, 'lua[ ]*([^%s])[ ]*([^%s]+)[ ]*(.*)')
    if not sub or not addon then
        return
    end
    if sub == 'i' then
        params = string.spaces_collapse(params)
        local t = string.psplit(params, ' ')
        local name = t[1]
        if type(_G[name]) == 'function' then
            _G[name](unpack(t, 2))
        end
    elseif sub == 'r' then
        AshitaCore:GetChatManager():QueueCommand('/addon reload ' .. addon, 1)
    elseif sub == 'u' then
        AshitaCore:GetChatManager():QueueCommand('/addon unload ' .. addon, 1)
    end
end

local execute_input_command = function(cmd)
--    print('execute_input_command: ' .. cmd)
    AshitaCore:GetChatManager():QueueCommand(cmd, 1)
end

windower.send_command = function(command)
--    print('SEND COMMAND: ' .. command)
    if command == nil or #command == 0 then
        return
    end
    local first, more = string.match(command, '([^;]+);?(.*)')
    first = string.trim(first)
    if string.sub(first, 1, 1)  == '@' then
        first = string.sub(first, 2)
    end
    if string.sub(first, 1, 4) == 'lua ' then
        execute_lua_command(first)
    elseif string.sub(first, 1, 5) == 'wait ' and #first > 5 then
        local time = tonumber(string.sub(first, 6))
        ashita.timer.once(time, windower.send_command, more)
        return
    elseif string.sub(first, 1, 6) == 'input ' and #first > 6 then
        execute_input_command(string.trim(string.sub(first, 6)))
    else
        print('SEND COMMAND(Unknown): ' .. first)
    end
    if more and #more > 0 then
        windower.send_command(more)
    end
end

windower.add_to_chat = function(mode, text)
    AshitaCore:GetChatManager():AddChatMessage(mode, text)
end

windower.to_shift_jis = function(string)
    return string
end

windower.dir_exists = function(dir)
    return ashita.file.dir_exists(dir)
end

windower.file_exists = function(file)
    return ashita.file.file_exists(file)
end

windower.create_dir = function(dir)
    return ashita.file.create_dir(dir)
end

windower.get_dir = function(dir)
    return ashita.file.get_dir(dir, '*', false)
end

windower.packets = windower.packets or {}

windower.packets.parse_action = function(packet)
    local res = {}
    if string.byte(packet) ~= 0x28 then
        return res
    end
    res['size'] = ashita.bits.unpack_be(packet, 32, 8)
    res['actor_id'] = ashita.bits.unpack_be(packet, 40, 32)
    res['target_count'] = ashita.bits.unpack_be(packet, 72, 10)
    res['category'] = ashita.bits.unpack_be(packet, 82, 4)
    res['param'] = ashita.bits.unpack_be(packet, 86, 16)
    res['unknown'] = ashita.bits.unpack_be(packet, 102, 16)
    res['recast'] = ashita.bits.unpack_be(packet, 118, 32)
    res['targets'] = {}

    local offset = 150
    for i = 1, res.target_count do
        local target = {}
        target['offset_start']                   = offset
        target['id']                             = ashita.bits.unpack_be(packet, offset,     32)
        target['action_count']                   = ashita.bits.unpack_be(packet, offset+32,   4)
        target['actions'] = {}
        offset = offset + 36
        for n = 1, target.action_count do
            local action = {}
            action['offset_start']               = offset
            action['reaction']                   = ashita.bits.unpack_be(packet, offset,     5)
            action['animation']                  = ashita.bits.unpack_be(packet, offset+5,  11)
            action['effect']                     = ashita.bits.unpack_be(packet, offset+16,  5)
            action['stagger']                    = ashita.bits.unpack_be(packet, offset+21,  6)
            action['param']                      = ashita.bits.unpack_be(packet, offset+27, 17)
            action['message']                    = ashita.bits.unpack_be(packet, offset+44, 10)
            action['unknown']                    = ashita.bits.unpack_be(packet, offset+54, 31)

            action['has_add_effect']             = ashita.bits.unpack_be(packet, offset+85,  1)
            action['has_add_effect']             = action.has_add_effect == 1
            offset = offset + 86
            if action.has_add_effect then
                action['add_effect_animation']   = ashita.bits.unpack_be(packet, offset,     6)
                action['add_effect_effect']      = ashita.bits.unpack_be(packet, offset+6,   4)
                action['add_effect_param']       = ashita.bits.unpack_be(packet, offset+10, 17)
                action['add_effect_message']     = ashita.bits.unpack_be(packet, offset+27, 10)
                offset = offset + 37
            end
            action['has_spike_effect']           = ashita.bits.unpack_be(packet, offset,     1)
            action['has_spike_effect']           = action.has_spike_effect == 1
            offset = offset + 1
            if action.has_spike_effect then
                action['spike_effect_animation'] = ashita.bits.unpack_be(packet, offset,     6)
                action['spike_effect_effect']    = ashita.bits.unpack_be(packet, offset+6,   4)
                action['spike_effect_param']     = ashita.bits.unpack_be(packet, offset+10, 14)
                action['spike_effect_message']   = ashita.bits.unpack_be(packet, offset+24, 10)
                offset = offset + 34
            end
            action['offset_end']                 = offset
            table.insert(target['actions'], action)
        end
        target['offset_end'] = offset
        table.insert(res['targets'], target)
    end

    return res
end

local PRIM_PREFIX = "__ashita_prim_"

local fontobj_table = {}
local primobj_table = {}

ashita.register_event('unload', function()
    for _, primobj_name in pairs(primobj_table) do
        AshitaCore:GetFontManager():Delete(PRIM_PREFIX .. primobj_name)
    end
    for _, fontobj_name in pairs(fontobj_table) do
        AshitaCore:GetFontManager():Delete(fontobj_name)
    end
end)

windower.prim = windower.prim or {}

windower.prim.create = function(name)
--    print('windower.prim.create')
    AshitaCore:GetFontManager():Create(PRIM_PREFIX .. name)
    table.insert(primobj_table, name)
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    prim:SetAutoResize(false)
end

windower.prim.delete = function(name)
--    print('windower.prim.delete')
    AshitaCore:GetFontManager():Delete(PRIM_PREFIX .. name)
    table.delete(primobj_table, name)
end

windower.prim.set_color = function(name, alpha, red, green, blue)
--    print(('windower.prim.set_color %i %i %i %i'):format(alpha, red, green, blue))
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
    prim:GetBackground():SetColor(math.d3dcolor(alpha, red, green, blue))
end

windower.prim.set_fit_to_texture = function(name, fit)
--    print('windower.prim.set_fit_to_texture ' .. tostring(fit))
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
end

windower.prim.set_position = function(name, x, y)
--    print('windower.prim.set_position ' .. x .. ', ' .. y)
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
    prim:SetPositionX(x)
    prim:SetPositionY(y)
end

windower.prim.set_size = function(name, x, y)
--    print('windower.prim.set_size ' .. x .. ', ' .. y)
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
    prim:GetBackground():SetWidth(x)
    prim:GetBackground():SetHeight(y)
end

windower.prim.set_texture = function(name, texture)
--    print('windower.prim.set_texture ' .. texture)
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
    prim:GetBackground():SetTextureFromFile(texture)
end

windower.prim.set_repeat = function(name, x_repeat, y_repeat)
--    print('windower.prim.set_repeat ' .. x_repeat .. ', ' .. y_repeat)
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
end

windower.prim.set_visibility = function(name, visible)
--    print('windower.prim.set_visibility')
    local prim = AshitaCore:GetFontManager():Get(PRIM_PREFIX .. name)
    if not prim then
        return
    end
    prim:SetVisibility(visible)
    prim:GetBackground():SetVisibility(visible)
end

windower.text = windower.text or {}

windower.text.create = function(name)
--    print('windower.text.create')
    AshitaCore:GetFontManager():Create(name)
    table.insert(fontobj_table, name)
end

windower.text.delete = function(name)
--    print('windower.text.delete')
    AshitaCore:GetFontManager():Delete(name)
    table.delete(fontobj_table, name)
end

windower.text.get_extents = function(name)
--    print('windower.text.get_extents')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return 0, 0
    end
    return text:GetWidth(), text:GetHeight()
end

windower.text.get_location = function(name)
--    print('windower.text.get_location')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return 0, 0
    end
    return text:GetPositionX(), text:GetPositionY()
end

windower.text.set_bg_border_size = function(name, px)
--    print('windower.text.set_bg_border_size')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:GetBackground():SetBorderSizes(px, px, px, px)
    text:GetBackground():SetBorderVisibility(px > 0)
end

windower.text.set_bg_color = function(name, alpha, red, green, blue)
--    print(('windower.text.set_bg_color %i %i %i %i'):format(alpha, red, green, blue))
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:GetBackground():SetColor(math.d3dcolor(alpha, red, green, blue))
end

windower.text.set_bg_visibility = function(name, visible)
--    print('windower.text.set_bg_visibility')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:GetBackground():SetVisibility(visible)
end

windower.text.set_bold = function(name, bold)
--    print('windower.text.set_bold')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetBold(bold)
end

windower.text.set_color = function(name, alpha, red, green, blue)
--    print('windower.text.set_color')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetColor(math.d3dcolor(alpha, red, green, blue))
end

windower.text.set_font = function(name, font1, font2, ...)
--    print('windower.text.set_font')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetFontFamily(font1)
end

windower.text.set_font_size = function(name, size)
--    print('windower.text.set_font_size')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetFontHeight(size)
end

windower.text.set_italic = function(name, italic)
--    print('windower.text.set_italic')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetItalic(italic)
end

windower.text.set_location = function(name, x, y)
--    print('windower.text.set_location')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetPositionX(x)
    text:SetPositionY(y)
end

windower.text.set_right_justified = function(name, justified)
--    print('windower.text.set_right_justified')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetRightJustified(justified)
end

windower.text.set_stroke_color = function(name, alpha, red, green, blue)
--    print('windower.text.set_stroke_color')
end

windower.text.set_stroke_width = function(name, width)
--    print('windower.text.set_stroke_width')
end

windower.text.set_text = function(name, string)
--    print('windower.text.set_text')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetText(string)
end

windower.text.set_visibility = function(name, visible)
--    print('windower.text.set_visibility')
    local text = AshitaCore:GetFontManager():Get(name)
    if not text then
        return
    end
    text:SetVisibility(visible)
end

windower.ffxi = windower.ffxi or {}

windower.ffxi.get_info = function()
    return {
--    day: int
--    moon: int                * Percentage
--    moon_phase: int
--    time: int
        ['zone'] = AshitaCore:GetDataManager():GetParty():GetMemberZone(0),
--    mog_house: bool
        ['logged_in'] = logged_in,
--    weather: int
        ['language'] = 'en',
    }
end

local jobs = {
    'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF',
    'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM',
    'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP',
    'DNC', 'SCH', 'GEO', 'RUN'
}

local function map_entity(entity)
    if entity and type(entity) == 'number' then
        entity = GetEntity(entity)
    end
    if not entity then
--        print 'id not found'
        return nil
    end

    local res = {}
    res['name'] = entity.Name
    res['claim_id'] = entity.ClaimServerId
    res['distance'] = entity.Distance
    res['facing'] = entity.Heading
    res['hpp'] = entity.HealthPercent
    res['id'] = entity.ServerId
    res['is_npc'] = true -- TODO
    res['mob_type'] = entity.EntityType
    res['model_size'] = entity.ModelSize
    res['speed'] = entity.Speed
    res['speed_base'] = entity.Speed2
    res['race'] = entity.Race
    res['status'] = entity.Status
    res['index'] = entity.TargetIndex
    res['x'] = entity.LocalX
    res['y'] = entity.LocalY
    res['z'] = entity.LocalZ
    res['target_index'] = 0 -- TODO
    res['fellow_index'] = 0 -- TODO
    res['pet_index'] = entity.PetTargetIndex
    res['tp'] = 0 -- TODO
    res['mpp'] = entity.ManaPercent
    res['charmed'] = false -- TODO
    res['in_party'] = false -- TODO
    res['in_alliance'] = false -- TODO
    res['valid_target'] = false -- TODO
--    print(dump(res))
    return res
end

windower.ffxi.get_player = function()
--    print('windower.ffxi.get_player')
    local entity = GetPlayerEntity()
    if entity == nil then
        return nil
    end
    local res = {}
    res['buffs'] = AshitaCore:GetDataManager():GetPlayer():GetBuffs()
    res['skills'] = {}
    res['vitals'] = {
        ['hp'] = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0),
        ['mp'] = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0),
        ['max_hp'] = AshitaCore:GetDataManager():GetPlayer():GetHealthMax(),
        ['max_mp'] = AshitaCore:GetDataManager():GetPlayer():GetManaMax(),
        ['hpp'] = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(0),
        ['mpp'] = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMPP(0),
        ['tp'] = AshitaCore:GetDataManager():GetParty():GetMemberCurrentTP(0),
    }
    res['jobs'] = {}
    res['name'] = entity.Name
--    linkshell: string
--    linkshell_rank: int
--    linkshell_slot: int
    res['main_job'] = jobs[AshitaCore:GetDataManager():GetPlayer():GetMainJob()] or 'NONE'
--    main_job_level: int
--    main_job_full: string
--    main_job_id: int
--    nation: int
    res['id'] = entity.ServerId
--    status: string
--    status_id: int
    res['index'] = entity.TargetIndex
--    sub_job: string
--    sub_job_level: int
--    sub_job_full: string
--    sub_job_id: int
    res['target_index'] = 0
    res['in_combat'] = (entity.Status == 1 or entity.Status == 3)
    res['autorun'] = {
--        x: float,
--        y: float,
--        z: float
    }
--    follow_index: int

--    print(dump(res))
    return res
end

local function map_party(res, prefix, mod, count)
    if count == 0 or count > 6 then
        return
    end

    for i = 0, count - 1 do
        local index = i + mod
        local id = prefix .. i
        res[id] = {}
--          hp: int
--          hpp: int
--          mp: int
--          mpp: int
--          tp: int
--          zone: int
        res[id]['name'] = AshitaCore:GetDataManager():GetParty():GetMemberName(index)
        res[id]['mob'] = map_entity(AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(index))
    end
end

windower.ffxi.get_party = function()
--    print('windower.ffxi.get_party')
    local res = {}
    map_party(res, 'p',   0, AshitaCore:GetDataManager():GetParty():GetAllianceParty0MemberCount())
    map_party(res, 'a1',  6, AshitaCore:GetDataManager():GetParty():GetAllianceParty1MemberCount())
    map_party(res, 'a2', 12, AshitaCore:GetDataManager():GetParty():GetAllianceParty2MemberCount())
--    party1_leader: int or nil (if not in a party)
--    party2_leader: int or nil (if no second party)
--    party3_leader: int or nil (if no third party)
--    alliance_leader: int or nil (if not in an alliance)

--    print(dump(res))
    return res
end

windower.ffxi.get_mob_by_id = function(id)
--    print('windower.ffxi.get_mob_by_id ' .. id)
    for index = 0, 2303 do
        local e = GetEntity(index)
        if e and e.ServerId == id then
            return map_entity(e)
        end
    end
    return nil
end

windower.ffxi.get_mob_by_index = function(index)
--    print('windower.ffxi.get_mob_by_index ' .. index)
    return map_entity(index)
end

windower.ffxi.get_mob_by_target = function(target)
--    print('windower.ffxi.get_mob_by_target ' .. target)
    local t = string.match(target, '<?(%a+)>?')
    return map_entity(ashita.ffxi.targets.get_target(t))
end

windower.play_sound = function(path)
    return ashita.misc.play_sound(path)
end