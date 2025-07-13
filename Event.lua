print("1")
check_delay = 2
loops = 0
function checkCpuUsage(varlist, netid)
    loops = loops + 1
    print("HI, INI ADALAH LOOP KE: "..loops)
    print("im sedang turu")
    sleep(20000)
end

addEvent(Event.varianlist, checkCpuUsage) 
listenEvents(999999)
