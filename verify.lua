myUsername = getUsername()
access_url = "https://raw.githubusercontent.com/Evan0A/Nuron_access/refs/heads/main/Factory_script.json?t="..os.time()
script_code = "normal"
json = nil

function getJson()
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
        json = result
    else
        print("Gagal eksekusi kode:", result)
    end
end

getJson()
function getHttp(url)
    print("http called")
    local client = HttpClient.new()
    client.url = url
    local result = client:request()
    if result.error ~= 0 then 
        --webhook report error
        return false 
    else
        if result.status == 200 then
            local success, data = pcall(json.decode, result.body)
            if success and type(data) == "table" then
                return data
            else 
                --webhook report 
            end 
        else 
            --webhook report 
        end 
    end 
    --webhook report
    return false
end

captain = getBot().index
function verifyMe()
    if getBot().index == captain then 
        local data = getHttp(access_url)
        if data then 
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
print("4")
print("found username: ")
print(verifyMe())
