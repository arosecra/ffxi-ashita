
string.unpack = function(str, fmt, pos)
    if string.match(fmt, 'b|q|B') then
        windower.error('No support for bit or bool formats in ' .. fmt)
    end
    fmt = string.gsub(fmt, 'C|q|B', 'b')

    return select(2, pack.unpack(str, fmt, pos))
end
