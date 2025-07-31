print("V16")
--[WORLD SETTINGS]--

world_farming = {"vaiiiii1140"} 
-- list of your pabrik world, all world must be have the same amount of row
door_farming = "ptv1945"
max_bot_perWorld = 3
spread_world = true 
--spread bot to every world, false if fill the first world 

world_seed = {"ptv1945farm"} -- world to take seed if bot dont have
door_seed = "ptvvl1140"


--[WORLD SAVE SETTINGS]-- 
world_save = {
    pack = { 
        world_pack = "world1",
        door_pack = "door1",
    },
    result = { -- result can be seed, flour, etc
        world_result = {"world1", "world2"},
        door_result = "door",
        max_drop = 10000 -- max drop for every world result
    },    
}

--PACK SETTING 
take_gems = true 
buy_pack = true 
pack = {
    pack_name = "world_lock",
    pack_id = {242}, 
    pack_price = 2000, 
    pack_minbuy = 1
}

-- MALADY
auto_malady = true 
-- auto trying to get malady grumble/chicken in a random world 
grumble_message = {
    "how much?????",
    "i dont like gay", 
    "just sybau alrdy",
    "ts aint tuff gng TwT"
}

-- ROTATION
auto_stop_level = true 
--auto disconnect if level reached 
minimum_level = 12
auto_turn_on_rotation = true 
--auto rotation if level has been reached


---SETTING---

auto_tutorial = true 
seed_id = 55
break_block = true
-- break the block before save it to world save(false if you farming for flour/blocks)
auto_grind = true 
world_grind = {"world1", "world2"}
door_grind = ""
--make sure the grinder didnt get blocked by any block
row_id = 4585 -- id of block that represent the Y row coordinate
pickaxe = {
    auto_take = true,
    world_door = "world|door"
}
delay = {
    warp = 10000, 
    punch = 160, 
    place = 160, 
    drop = 1000, 
    buy = 1000
}

report_error = true 
-- if true, this code will send a webhook to NEXORA store if there is an error with the web side 
-- (i wont take your personal information(such as world, door, etc), and your cpu will be safe)
-- false if you dont want to

accessUrl = "https://raw.githubusercontent.com/Evan0A/Nuron_access/refs/heads/main/Factory_script.json"
script_code = "NORMAL"
access_url = ""
bot_indexes = {}
botCount = 0 
captain = 0
myFarm, myRow = nil
myUsername = getUsername()
row_list = {}
seed_list = {}
seed_index = 1
malady_safe = {3,4}
valid = false
json = nil

function isInDoor()
    if getBot():getWorld():getTile(getBot().x, getBot().y).fg == 6 then 
        return true 
    end 
    return false 
end

function warp(world, id)
    world = world:upper()
    local id = id or ''
    local nuked = 0
    local stuck = false
    if not getBot():isInWorld(world) then
        getBot():leaveWorld()
        sleep(2000)
        while not getBot():isInWorld(world) and nuked < 5 do
            while getBot().status ~= BotStatus.online do
                getBot().auto_reconnect = true
                sleep(5000)
            end
            getBot():warp(world, id)
            sleep(delay.warp)
            nuked = nuked + 1
            if nuked >= 5 then 
                return false
            end
        end
    else 
        while getBot():isInWorld(world) and getBot():getWorld():getTile(getBot().x, getBot().y).fg == 6 and id ~= '' do 
            getBot():warp(world, id)
            sleep(delay.warp)
            stuck = stuck + 1 
            if stuck >= 5 then return false end 
        end 
    end
    return true
end

function getJson()
    print("entering getJson")
    local client = HttpClient.new()
    client.url = "https://raw.githubusercontent.com/Evan0A/Module/refs/heads/main/dkjson.lua"

    local code = client:request()  -- Dapatkan isi file Lua sebagai string
    local chunk, err = load(tostring(code.body))

    if not chunk then
        print("Gagal load kode:", err)
        return
    end

    local success, result = pcall(chunk)  -- Jalankan chunk dengan aman
    if success then
        print("success getting json")
        client.url = nil 
        json = result
    else
        print("Gagal eksekusi kode:", result)
    end
end

function getHttp(url)
    print("getHttp")
    local client = HttpClient.new()
    client.url = url
    local result = client:request()
    if result.error ~= 0 then 
        print("error result: "..result.error.." | url: "..url)
        --webhook report error
        return false 
    else
        if result.status == 200 then
            local success, data = pcall(json.decode, result.body)
            if success and type(data) == "table" then
                print("success decode result")
                return data
            else 
                print("failed decode data")
                --webhook report 
            end 
        else 
            print("web error") 
            --webhook report 
        end 
    end 
    --webhook report
    return false
end



function verifyMe()
    print("entering verify")
    if getBot().index == captain then 
        local data = getHttp(accessUrl)
        if data then
            print("verify data true")
            local found = false 
            for _, person in pairs(data.access) do 
                if person.username == myUsername then
                    local yesyes = false
                    for _, tipe in ipairs(person.type) do 
                        if tipe:upper() == script_code:upper() then 
                            yesyes = true 
                            break
                        end 
                    end 
                    if yesyes then 
                        found = true 
                        valid = true 
                        print("Username valid, thanks for buying NEXORA Factory script!!!")
                        --webhook 
                        return true 
                    else 
                        valid = false 
                        print("Right person, wrong code...")
                        --webhook 
                        return false
                    end 
                end 
            end
            if not found then
                print("Can not find your username ")
                --webhook 
                return false 
            end
        end 
    end 
end 

function sensor(teks)
    local panjang = #teks
    if panjang <= 4 then
        return string.rep("X", panjang)
    end
    local awal = string.sub(teks, 1, panjang - 4)
    return awal .. "XXXX".."(".. getBot().index..")"
end

function tableCekDouble(arr, val) 
    local available = false
    for i = 1, #arr do 
        if arr[i] == val then 
            available = false
        end 
    end 
    if not available then 
        table.insert(arr, val) 
        return true 
    end 
    return false 
end

function tableIsIn(arr, val)
    local val = tostring(val):upper()
    for _, a in pairs(arr) do 
        if tostring(a):upper() == val then 
            return true 
        end 
    end 
    return false 
end

function getCaptain(bool)
    bool = bool or false
    botCount = #getBots()
    getBot().custom_status = ""
    sleep(1000)
    if #getBots() == 1 then 
        captain = getBot().index
        table.insert(bot_indexes, tonumber(getBot().index))
        return true
    end
    getBot().custom_status = "REST VERIFICATION 1"
    sleep(10000)
    for i = 1, botCount do 
        if getBot(i).custom_status == "REST VERIFICATION 1" and getBot(i):isRunningScript() then 
            tableCekDouble(bot_indexes, tonumber(getBot(i).index))
        end 
    end
    sleep(5000)
    captain = bot_indexes[math.ceil(#bot_indexs / 2)]
    if getBot().index == captain then 
        print("changed captain rest: "..getBot(captain).name)
    else 
        getBot().custom_status = string.format("Following captain(%s)", getBot(captain).name)
    end
end

function getEvenSpreadWorldRow()
    print("entering getEvenSpreadWorldRow()")

    if not bot_indexs then
        print("❌ bot_indexs is nil")
        return false, false
    end

    if not world_farming then
        print("❌ world_farming is nil")
        return false, false
    end

    local world_count = #world_farming
    print("✅ world_count: " .. world_count)

    local total_capacity = world_count * max_bot_perWorld
    print("✅ total_capacity: " .. total_capacity)

    for i, bot_index in ipairs(bot_indexs) do
        print("🔁 Checking bot_indexs[" .. i .. "] = " .. tostring(bot_index))

        if bot_index > total_capacity then
            print("❌ Invalid bot_index: " .. bot_index .. " (melebihi kapasitas)")
            return false, false
        end

        local row = math.floor((bot_index - 1) / world_count) + 1
        local world_index = ((bot_index - 1) % world_count) + 1

        print("➡️ Calculated row = " .. row)
        print("➡️ Calculated world_index = " .. world_index)

        local farm = world_farming[world_index]
        if not farm then
            print("❌ world_farming[" .. world_index .. "] is nil!")
            return false, false
        end

        local myFarm = farm:upper()
        local myRow = row

        print("✅ Assigned world: " .. myFarm .. " | row: " .. myRow)
        return myFarm, myRow
    end

    print("❌ Tidak ada bot_index yang valid.")
    return false, false
end

function getRow()
    print("entering getRow()")
    warp(myFarm, door_farming)
    if getBot():isInWorld(myFarm) then 
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

function searchRow(row)
    print("entering SearchRow()")
    if not getBot():isInWorld(myFarm) then
        warp(myFarm, door_farming)
    end 
    if getBot():isInWorld(myFarm) then 
        local worldRow = {}
        for _, coord in pairs(row_list[myFarm].coords) do 
            table.insert(worldRow, coord.y)
        end 
        table.sort(worldRow, function(a, b)
            return a > b
        end)
        return row_list[myFarm].coords[row].y
    end 
end 

function isInRow()
    print("entering isInrow()")
    if getBot():isInWorld(myFarm) and not isInDoor() then
        getBot():findPath(row_list[myFarm].coords[myRow].x, row_list[myFarm].coords[myRow].y)
        sleep(100)
    end 
    if getBot().y == searchRow(myRow) then 
        return true 
    end 
    return false 
end 

function startup()
    local function tutorial()
        if getBot().level < 6 and auto_tutorial then
            local tutorial = getBot().auto_tutorial
            tutorial.enabled = true
            tutorial.auto_quest = true
            tutorial.set_as_home = true
            tutorial.set_high_level = true
            tutorial.detect_tutorial = true
            tutorial.set_random_skin = true
            tutorial.set_random_profile = true
        end
        while getBot().level < 6 do 
            sleep(2500)
        end
    end 
    local function takePickaxe()
        while getBot():getInventory():getItemCount(98) == 0 and pickaxe.auto_take do
            getBot().wear_storage = pickaxe.world_door
            getBot().auto_wear = true 
            if getBot():getInventory():getItemCount(98) ~= 0 then 
                sleep(1000)
                getBot():wear(98)
                sleep(2000)
                return true
            end
        end
    end 
    
    tutorial()
    takePickaxe()
end

function malady()
    local function getWorld(n)
        local chars = "1234567890abcdefghijklmnopqrstuvwxyz"
        local result = ""
        for i = 1, length do
            local randIndex = math.random(#chars)
            result = result .. chars:sub(randIndex, randIndex)
        end
        return result
    end
    local function countPlayers()
        local count = 0
        for _, plr in pairs(getBot():getWorld():getPlayers()) do 
            if plr.name ~= getBot().name then 
                count = count + 1 
            end 
        end
        return count
    end 
    local function removeSickness()
        if getBot().malady == 1 or getBot().malady == 2 and getBot().status == 1 then 
            getBot().auto_malady.enabled = false
            getBot().auto_reconnect = true
            math.randomseed(os.time())
            local randomStr = getWorld(8)   
            warp(randomStr, "")
            getBot().auto_malady.enabled = true
            --webhook malady got torn/gem
            while getBot().malady == 1 or getBot().malady == 2 do
                while getBot().status ~= 1 do 
                    sleep(10000)
                end
                if getBot():getWorld().name ~= randomStr and getBot().status == 1 then 
                    getBot().auto_malady.enabled = false
                    warp(randomStr, "")
                    getBot().auto_malady.enabled = true
                end 
                if countPlayers() >= 1 and getBot().status == 1 then
                    getBot().auto_malady.enabled = false
                    randomStr = getWorld(8)
                    warp(randomStr)
                    getBot().auto_malady.enabled = true
                end
                sleep(1 * 60 * 1000)
            end
        end
        return true
    end
    local function getMalady()
        if not tableIsIn(malady_safe, getBot().malady) and removeSickness() then 
            getBot().auto_malady.enabled = false
            --webhook 
            local randomStr = getWorld(8)
            warp(randomStr)
            getBot().auto_malady.enabled = true
            getBot().auto_reconnect = true
            print("world mal: "..randomStr)
            while not tableIsIn(malady_safe, getBot().malady) do
                while getBot().status ~= 1 do 
                    sleep(10000)
                end
                if getBot():getWorld().name ~= randomStr and getBot().status == 1 then 
                    getBot().auto_malady.enabled = false 
                    warp(randomStr)
                    getBot().auto_malady.enabled = true
                end
                if countPlayers() >= 1 and getBot().status == 1 then 
                    getBot().auto_malady.enabled = false
                    randomStr = getWorld(8)
                    getBot().auto_malady.enabled = true
                end
                print("in loop cekmalady, bot: "..getBot().name)
                if getBot().malady == 3 or getBot().malady == 4 then 
                    break 
                end
                restAll()
                sleep(delay_malady * 60 * 1000)
            end 
            --webhoom bot got grumble/chicken
        end
        getBot().auto_malady.enabled = true
    end
    getMalady()
end 


function takeSeed()
    if getBot().status == 1 and getBot():getInventory():getItemCount(seed_id) == 0 then 
        if #world_seed >= seed_index then 
            -- wbhook world seed empty
        end
        for i = seed_index, #world_seed do 
            warp(world_seed[seed_index], door_seed)
            for _, obj in pairs(getBot():getWorld():getObjects()) do 
                if obj.id == seed_id then 
                    seed_index = i
                    getBot():findPath(math.floor(obj.x/32), math.floor(obj.y/32))
                    sleep(100)
                    getBot():collectObject(obj.oid, 2)
                    while getBot():getInventory():getItemCount(seed_id) == 0 and getBot().status == 1 do
                        sleep(1000)
                    end 
                    if getBot():getInventory():getItemCount(seed_id) ~= 0 then 
                        break 
                    end 
                end 
            end 
        end 
    end 
end

function ptht()
    if getBot():isInWorld(myFarm) and not isInDoor() then 
        local y = myRow
        for x = 0,99 do 
            local tiles = getBot():getWorld():getTile(x,y) 
            while tiles.y == myRow and getBot():getWorld():getTile(tiles.x, tiles.y + 1).fg ~= 0 and getBot().status == 1 and getInfo(getBot():getWorld():getTile(tiles.x, tiles.y + 1).fg).collision_type == 1  do
                getBot():findPath(tiles.x, tiles.y)
                getBot():place(tiles.x, tiles.y, seed_id)
                sleep(delay.place)
            end 
        end 
    end 
end 

function plant()
    if getBot():isInWorld(myFarm) and not isInDoor() then 
        local y = myRow
        for x = 0,99 do 
            local tiles = getBot():getWorld():getTile(x,y) 
            while tiles.y == myRow and getBot():getWorld():getTile(tiles.x, tiles.y + 1).fg ~= 0 and getBot().status == 1 and getInfo(getBot():getWorld():getTile(tiles.x, tiles.y + 1).fg).collision_type == 1 and getBot():getInventory():getItemCount(seed_id) ~= 0 do
                getBot():findPath(tiles.x, tiles.y)
                getBot():place(tiles.x, tiles.y, seed_id)
                sleep(delay.place)
            end 
        end 
    end 
end 

function checkConfig()
    local num = #world_farming * max_bot_perWorld 
    local valid = true
    if #bot_indexs <= num then
        valid = false 
    end 
    if #world_farming == 0 or max_bot_perWorld == 0 then 
        valid = false 
    end
    if not valid then
        print("invalid config for bot: "..getBot().name.."("..getBot().index..")")
        if getBot().index == captain then 
            --webhook
        end 
        getBot():stopScript()
    end 
end

function startThisSoGoodScriptAnjay()
    getCaptain()
    if getBot().index == captain then 
        getJson()
        verifyMe()
    end 
    if valid then 
        takeSeed()
        getEvenSpreadWorldRow()
        getRow()
        searchRow(myRow)
        isInRow()
    end 
end 
 startThisSoGoodScriptAnjay()   
