SSID    = "SSID"
APPWD   = "pwd"
CMDFILE = "ping.lua"   -- File that is executed after connection

wifiTrys     = 15     -- Counter of trys to connect to wifi
NUMWIFITRYS  = 200    -- Maximum number of WIFI Testings while waiting for connection

function launch()
  print("Connected to WIFI!")
  print("IP Address: " .. wifi.sta.getip())
  -- Call our command file. Note: if you foul this up you'll brick the device!
  -- dofile("security.lua")
  -- makeConn()
end

function checkWIFI() 
  if ( wifiTrys > NUMWIFITRYS ) then
    print("Sorry. Not able to connect")
  else
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr ~= nil ) and  ( ipAddr ~= "0.0.0.0" ) )then
      local my_timer = tmr.create()
      my_timer:alarm(500 , tmr.ALARM_SINGLE , launch )
    else
      -- Reset alarm again
      local my_timer = tmr.create()
      my_timer:alarm(2500 , tmr.ALARM_SINGLE , checkWIFI )
      print("Checking WIFI..." .. wifiTrys)
      wifiTrys = wifiTrys + 1
    end 
  end 
end

print("-- Starting up! ")

-- Lets see if we are already connected by getting the IP
ipAddr = wifi.sta.getip()
if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
  -- We aren't connected, so let's connect
  print("Configuring WIFI....")
  wifi.setmode( wifi.STATION )
  local wifi_config = {}
  wifi_config.ssid = SSID
  wifi_config.pwd = APPWD
  wifi.sta.config(wifi_config)
  print("Waiting for connection")
  local my_timer = tmr.create()
  my_timer:alarm(2500 , tmr.ALARM_SINGLE , checkWIFI )
else
 -- We are connected, so just run the launch code.
 launch()
end
