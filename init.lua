local json = require "cjson"
print("Connecting to wifi...")
wifi.setmode(wifi.STATION)
wifi.sta.config("0EF623","SABAS1080*_")

local ip = wifi.sta.getip()

function updateWeather()
    local conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload)
        print("Conn: ")
        print(conn)
        print("Payload: ")
        -- print(payload)
        local payload = string.match(payload, "{.*}")
        print(payload)

        weather = nil
        if payload ~= nil then
          weather = json.decode(payload)
          print("weather:")
          print(weather.name)
        end

        payload = nil
        conn:close()
        conn = nil
    end )

    print(ip)
      conn:connect(80, "162.243.133.52")
    conn:send("GET /api/v1/pokemon/1/ HTTP/1.1\r\n"
    .."Host: pokeapi.co\r\n"
    .."Cache-Control: no-cache\r\n"
    .."\r\n")
    conn = nil

end

tmr.alarm(0, 1000, 1, function()
    print(".")
    ip = wifi.sta.getip()
    if ( ( ip ~= nil ) and  ( ip ~= "0.0.0.0" ) )then
        print(ip)
        tmr.stop(0)
        updateWeather()
    end
end )
