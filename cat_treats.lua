local motion_idx = 7

local servo_idx = 8

gpio.mode(motion_idx, gpio.INPUT)

gpio.mode(servo_idx, gpio.OUTPUT)

-- Set the initial position of the servo motor
pwm.setup(servo_idx, 50, 75) -- Adjust the pulse width values for your servo motor
pwm.start(servo_idx)


function handleConnection(conn)
    -- Send a welcome message to the client
    conn:send("Welcome to the server!\n")
    -- Close the connection when the client disconnects
    conn:on("disconnection", function(conn)
      print("Client disconnected")
    end)

    
  end



print("creating TCP server")
sv = net.createServer(net.TCP)
cooldown_timer = tmr.create()

sv:listen(80, function(conn)
    print("Client connected")
    local treats_ready = true
    local cooldown_active = true
    local cooldown_period = 15000
    local auto_active = false;

    -- Handle the incoming connection
    handleConnection(conn)

    conn:on("receive", function (conn, msg)
        if string.match(msg, "dispense") then
            dispense_treat()
        end
        if string.match(msg, "auto off") then
            auto_active = false
        end
        if string.match(msg, "auto on") then
            auto_active = true
        end
    end)

    -- Define a function to check for motion and send a message to the client
    function check_for_motion()
        -- TODO: have a "cooldown" timer of sorts to ensure not activated too often
        local motion_detected = gpio.read(motion_idx)
        if motion_detected == gpio.HIGH then
            if treats_ready and auto_active then
                dispense_treat()
            else
                if auto_active then
                    conn:send("Still within cooldown...\n")
                end
            end
        end
    end
    function dispense_treat()
        conn:send("Dispensing treat!\n")
        pwm.setduty(servo_idx, 25) -- Adjust the duty cycle value to control the angle of the servo
        tmr.delay(1000000) -- Adjust the delay based on the time required to dispense a treat
        pwm.setduty(servo_idx, 75) -- Adjust the duty cycle value to return the servo to its initial position
        conn:send("Treat dispensed!\n")
        -- begin cooldown period
        if cooldown_active then
            treats_ready = false 
            cooldown_timer:start()
        end
    end

    function reset_cooldown()
        treats_ready = true
        conn:send("Cooldown over!\n");
    end

    -- create 15s cooldown timer
    -- will set treats_ready to false while still within cooldown
    cooldown_timer:register(cooldown_period, tmr.ALARM_SEMI, reset_cooldown)

    -- Call the checkForMotion function every 1 second
    tmr.create():alarm(1000, tmr.ALARM_AUTO, check_for_motion)
  end)
