local json = require "cjson"
print("Connecting to wifi...")
wifi.setmode(wifi.STATION)
wifi.sta.config("XXXX","PASSWORD")

local ip = wifi.sta.getip()

function init_spi_display()
     -- Hardware SPI CLK  = GPIO14-->SCL OLED
     -- Hardware SPI MOSI = GPIO13-->SDA OLED
     -- Hardware SPI MISO = GPIO12 (not used)
     -- CS, D/C, and RES can be assigned freely to available GPIOs
     cs  = 8 -- GPIO15, pull-down 10k to GND
     dc  = 4 -- GPIO2 --> D/C OLED
     res = 0 -- GPIO16 --> RST OLED

     spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
     disp = u8g.ssd1306_128x64_spi(cs, dc, res)
end

function xbm_picture()
     disp:setFont(u8g.font_6x10)
     disp:drawStr( 62, 10, "Ability:")
     disp:drawStr( 62, 62, weather.name)
     disp:drawXBM( 0, -5, 60, 60, xbm_data )
end

function bitmap_test(delay)
     file.open("prueba.MONO", "r")
     xbm_data = file.read()
     file.close()

      disp:firstPage()
      repeat
           xbm_picture()
      until disp:nextPage() == false

      tmr.wdclr()
end

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
          print("Ability:")
          print(weather.name)
          bitmap_test()
        end

        payload = nil
        conn:close()
        conn = nil
    end )

    print(ip)
      conn:connect(80, "162.243.133.52")
    conn:send("GET /api/v1/ability/5/ HTTP/1.1\r\n"
    .."Host: pokeapi.co\r\n"
    .."Cache-Control: no-cache\r\n"
    .."\r\n")
    conn = nil

end
init_spi_display()

tmr.alarm(0, 1000, 1, function()
    print(".")
    ip = wifi.sta.getip()
    if ( ( ip ~= nil ) and  ( ip ~= "0.0.0.0" ) )then
        print(ip)
        tmr.stop(0)
        updateWeather()
    end
end )

