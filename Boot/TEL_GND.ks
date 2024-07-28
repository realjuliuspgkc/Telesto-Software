clearscreen.

     local _GND_PAD is ship:partstagged("GND_PAD")[0].
    _GND_PAD:getmodule("ModuleGenerator"):doaction("activate generator", true).

UNTIL AG6 {
    PRINT "GROUND CPU: " + time at (0,1).
    PRINT "PRESS AG6 TO START COUNT" at (0,2).
}

core:part:getmodule("kOSProcessor"):doevent("Open Terminal"). 

runOncePath("0:/SaturnAerospace/Telesto/GROUND/countdown.ks").