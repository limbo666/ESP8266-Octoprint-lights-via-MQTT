**A Nodemcu(lua) based solution for Octoprint. Requires MQTT plugin for Octoprint.** 

Block diagram
![concept](https://github.com/limbo666/ESP8266-Octoprint-lights-via-MQTT/blob/master/images/block%20diagram.png?raw=true)


The solution can turn on lights when printing process starts, change color on led strip when print is finished / canceled, turn off the lights after specific time of inactivity, receive manual commands to turn off/on the lights and more.

**Functions:** 

- Turns on the lights when printer starts.
- Turns off the lights after printer inactivity. 10 minutes after last job done, 30 minutes if no action is reported by printer.
- Indicates with color the job result. GREEN = success, RED= Failed/Canceled
- Indicated file loaded / unloaded
- Manual control option via MQTT messages
- Highly customizable

 **How to build**

1. Connect LED strip to WEMOS 

   D1 mini 5v		-->		5V 

   GND		-->		G 

   DATA		-->		D4

2. Build NodeMCU firmare with the appropriate modules Navigate to https://nodemcu-build.com/ and use the service to build the firmware. You should select the following 10 modules: *file, gpio, mqtt, net, node, tmr, uart, wifi, ws2812 and  ws2812_effects* under *master branch*. Two emails will be dispatched to your email. The first it is just informational to indicate the start of building process and on the second you will find the download links. Using the integer firmware flavor is just fine for this application.

3. Flash WEMOS D1 mini with NodeMCU firmware Use the latest Esptool from here https://github.com/marcelstoer/nodemcu-pyflasher/releases to flash the firmware to the board.

4. Use your proffered lua upload software to connect with the board and edit the files. 

   *Note: After firmware flashing a format filesystem will be performed on the board. This may take few seconds and it will be indicated on the software.*

   Important:  You must alter source code by setting **WiFi connection info** and **MQTT server IP address and credentials**

   Then, upload lua files to WEMOS D1 mini
