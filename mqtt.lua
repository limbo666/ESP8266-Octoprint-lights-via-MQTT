MQTTAddress="192.168.128.10"
MQTTUser="user"
MQTTPass="password"

Status="idle"
globalTime=1800 --time to turn off lights if there is no action at all
actionTime=-1 --time to change lights mode (turnoff/change color/change brightness) from last action triggered
autotmr = tmr.create()
autotmr:register(1000, tmr.ALARM_AUTO, function (t) 
	if globalTime >0 then 
		globalTime =globalTime - 1
	elseif  globalTime ==0 then -- if global time is expired then turn off the lights
		setLeds(0,0,0,0)
		actionTime=-1
		globalTime=-1 
	else
	end
	if actionTime>0 then
		actionTime=actionTime-1
	elseif actionTime ==0 then
		if Status =="done" then -- if coming from done job then turn off the light
			setLeds(0,0,0,0)
			actionTime=-1
		elseif Status =="tempcolor" then -- if coming temp indication and need to retunr to previous state
			ws2812.write(buffer2)
			actionTime=-1
		elseif Status =="test" then -- if test commnd is issued
			setLeds(50,100,0,2)
			actionTime=5
			Status="done"
		end 
	else
		
	end
--	if actionTime>0 then
--		print("Action time remaining: "..actionTime) -- diagnostic use
--	end
end)
autotmr:start()
-- init mqtt client with logins, keepalive timer 120sec
m = mqtt.Client("3D Printer Lights", 120,  MQTTUser, MQTTPass) 
m:on("connect", function(client) print ("Connected") end)
m:on("offline", function(client) print ("Offline") end)
-- on publish message receive event
m:on("message", function(client, topic, data)
 -- print(topic .. ":" )
 -- if data ~= nil then
  --  print(data)
 -- end

-- below checking topic texts
if (string.find(topic, "FileSelected", 1, true) ~= nil) then
	buffer2:replace(buffer1)
	setLeds(60,60,60,2)
	Status="tempcolor"
	actionTime = 30 --half minute indication
	globalTime = 1800 --reset global timer
elseif (string.find(topic, "FileDeselected", 1, true) ~= nil) then
	buffer2:replace(buffer1)	
	setLeds(60,0,60,2) 
	Status="tempcolor"
	actionTime = 30 --half minute indication
	globalTime = 1800  --reset global timer
elseif (string.find(topic, "PrintCancelled", 1, true) ~= nil) then
	setLeds(150,0,0,1)
	Status="done"
	actionTime = 600 
	globalTime = 1800 --reset global timer
elseif(string.find(topic, "PrintStarted", 1, true) ~= nil) then
	setLeds(100,100,100,0)
	Status="printing"
	actionTime = -1
	globalTime = -1
elseif(string.find(topic, "PrintFailed", 1, true) ~= nil) then
	setLeds(30,300,300,1)
	setLeds(100,0,0,2)
	Status="failed"
	actionTime = -1
	globalTime = 1800 --reset global timer
elseif(string.find(topic, "PrintDone", 1, true) ~= nil) then
	setLeds(30,30,30,1)
	setLeds(0,100,0,2)
	actionTime=600 --ten minutes timer to turn of the lights
	Status="done"
	globalTime = 1800 --reset global timer
elseif(string.find(topic, "progress", 1, true) ~= nil) then
	--FOR FUTURE USE
	--you can set here any action you like to take place when the print percentage is changed
	--for instance change gradually the led color according to proccess 
	--example code:
	--if (string.find(data, "80", 1, true) ~= nil) then
	--	setLes(50,100,100,0)
	--end
   print(data) 
end


-- below checking data texts 
if (string.find(data, "Cancelling", 1, true) ~= nil) then --this event is coming from printer
	setLeds(50,0,0,2)
	Status="done"
	actionTime = 600
	globalTime = 1800 --reset global ime to wait 30 minutes until turn off
elseif (string.find(data, "Printing", 1, true) ~= nil) then --this event is coming from printer
	setLeds(100,100,100,0)
	Status="done"
	actionTime = -1
	globalTime = -1
elseif(string.find(data, "turnon", 1, true) ~= nil) then  --this event is for manual control 
	setLeds(100,100,100,0)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "turnred", 1, true) ~= nil) then --this event is for manual control 
	setLeds(100,0,0,1)
	setLeds(0,0,0,2)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "turngreen", 1, true) ~= nil) then --this event is for manual control 
	setLeds(0,100,0,1)
	setLeds(0,0,0,2)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "turnblue", 1, true) ~= nil) then --this event is for manual control 
	setLeds(0,0,100,1)
	setLeds(0,0,0,2)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "turnpurple", 1, true) ~= nil) then --this event is for manual control 
	setLeds(100,0,100,1)
	setLeds(0,0,0,2)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "turnoff", 1, true) ~= nil) then --this event is for manual control 
	setLeds(0,0,0,0)
	actionTime=-1
	Status="idle"
elseif(string.find(data, "testlights", 1, true) ~= nil ) then  --this event is for manual control and test
	setLeds(50,0,100,1)
	actionTime=5
	Status="test"
end

end)

-- on publish overflow receive event
m:on("overflow", function(client, topic, data)
  print(topic .. " partial overflowed message: " .. data )
end)

-- for TLS: m:connect(MQTTAddress, secure-port, 1)
m:connect(MQTTAddress, 1883, 0, function(client) -- verify connection port here
  print("ΜQΤΤ connected successfully")
  
--Printer events below
	client:subscribe("octoPrint/event/PrinterStateChanged", 0, function(client) print("OK") end)
 	client:subscribe("octoPrint/event/PrintCancelled", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/PrintCancelling", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/PrintStarted", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/PrintFailed", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/PowerOff", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/PrintDone", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/FileSelected", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/event/FileDeselected", 0, function(client) print("OK") end)
	client:subscribe("octoPrint/progress/printing", 0, function(client) print("OK") end)
-- Manual control events below 
	client:subscribe("3DPrinter/manualcontrol/lights", 0, function(client) print("OK") end)
  -- Optional: you can send a connection message to MQTT 
 -- client:publish("3DPrinter/event/lightsstatus",  "connected", 0, 0, function(client) print("message sent") end)
end,
function(client, reason)
  print("MQTT connection failed. Code: " .. reason)
--Code explanation
--Code -5 	SERVER NOT FOUND
--Code -4 	NOT A CONNACK MSG
--Code -3 	FAIL DNS
--Code -2 	TIMEOUT RECEIVING
--Code -1 	TIMEOUT SENDING
--Code 1 	REFUSED PROTOCOL VER
--Code 2 	REFUSED ID REJECTED
--Code 3 	REFUSED SERVER_UNAVAILABLE
--Code 4 	REFUSED BAD_USER OR PASS
--Code 5 	REFUSED NOT AUTHORIZED
end)

