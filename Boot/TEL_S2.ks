clearScreen.
print "Waiting For Message - S2".

until false {
    wait until not core:messages:empty. // Waits until the core recieves a message
    set _MSG_CORE_RECIEVED to core:messages:pop. // Assigns variable to message recieved
    set _DECODEDMSG to _MSG_CORE_RECIEVED:content. // Stores message in a decoded format

    if _DECODEDMSG = "LIFTOFF" {        
        runOncePath("0:/SaturnAerospace/Telesto/VEHICLE/flight.ks"). // Runs path of recieved message
    } else if _DECODEDMSG = "STATIC FIRE" {
        runoncepath("0:/SaturnAerospace/Telesto/GROUND/static_fire.ks").
    }
}