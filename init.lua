print("Starting")
local SSID ="SSID_HERE" 
local PASS ="WIFI_PASSWORD_HERE" 

print("Initializing led strip")
g=0; r=0; b=0 
ws2812.init()
buffer1 = ws2812.newBuffer(12, 3) -- twelve leds, three colors
buffer2 = ws2812.newBuffer(12, 3) -- buffer2 is used to hold colors when temporary change is applied 
function setLeds(r,g,b,mode) -- set to receive RGB signal not GRB
	if mode== 0 then
		print("All leds: R"..r.." G"..g.." B"..b) 
		for i=12,1,-1 do 
			print(i)  -- acts as a tiny delay to load buffer correctly
			buffer1:set(i, g,r,b)
		end
		i=0
	elseif mode == 1 then
		print("Odd leds: R"..r.." G"..g.." B"..b) 
		for i=11,1,-2 do 
			print(i) -- acts as a tiny delay to load buffer correctly
			buffer1:set(i, g,r,b)
		end 
		i=0
	elseif mode == 2 then
		print("Even leds: R"..r.." G"..g.." B"..b) 
		for i=12,2,-2 do 
			print(i) -- acts as a tiny delay to load buffer correctly
			buffer1:set(i, g,r,b)
		end
		i=0
	end
ws2812.write(buffer1)
end 

setLeds(60,60,0,2)

print("Setting WiFi parameters") 
wifi.setmode(wifi.STATION) 
wifi.sta.autoconnect(1)
station_cfg={} 
station_cfg.ssid= SSID
station_cfg.pwd= PASS
station_cfg.save=true 
wifi.sta.config(station_cfg) 
wifi.sta.connect()

ipTmr = tmr.create()
ipTmr :register(1000, tmr.ALARM_AUTO, function (t)
print("Waiting for IP address")
ip= wifi.sta.getip()
	if ip ~= nil then
		print("IP address is: "..ip)
		ipTmr:stop()
		ipTmr:unregister()
		setLeds(0,0,50,2)
		if file.exists("mqtt.lua") then
			print("Starting mqtt.lua")			
			dofile("mqtt.lua")
		end
	end
end)
ipTmr :start()
