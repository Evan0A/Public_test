row_list = {}
row_id = 4584
print("v3")
function getRow(world)
    if getBot():isInWorld(world) then 
        row_list[world] = row_list[world] or {coords = {}}
        local used_y = {}

        for _, tiles in pairs(getBot():getWorld():getTiles()) do 
            if tiles.fg == row_id and not used_y[tiles.y] then
                table.insert(row_list[world].coords, {x = tiles.x, y = tiles.y})
                used_y[tiles.y] = true
            end 
        end
    end
    return true 
end


function calculateRow(world)
    local rownum = {}
    local y_set = {}

    for _, coord in pairs(row_list[world].coords) do
        if coord.y ~= nil and not y_set[coord.y] then
            table.insert(rownum, coord.y)
            y_set[coord.y] = true
        end
    end
    
    table.sort(rownum)

    local y_to_row = {}
    for i, y in ipairs(rownum) do
        y_to_row[y] = i
    end

    for _, coord in pairs(row_list[world].coords) do
        coord.row = y_to_row[coord.y]
    end
end

function dump(tbl, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(spacing .. tostring(k) .. " = {")
            dump(v, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

getRow(getBot():getWorld().name)
dump(row_list)
calculateRow(getBot():getWorld().name)
dump(row_list, 1)
