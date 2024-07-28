clearScreen.
print "Waiting For Message - Narvi".

until false {
    wait until not core:messages:empty. // Waits until the core recieves a message
    set _MSG_CORE_RECIEVED to core:messages:pop. // Assigns variable to message recieved
    set _DECODEDMSG to _MSG_CORE_RECIEVED:content. // Stores message in a decoded format

    if _DECODEDMSG = "Init" {        
        runOncePath("0:/SaturnAerospace/Telesto/CAPSULE/flight.ks"). // Runs path of recieved message
    } else if _DECODEDMSG = "ABORT S1" {
        runoncepath("0:/SaturnAerospace/Telesto/CAPSULE/Abort/abort_s1.ks").
    } else if _DECODEDMSG = "ABORT S2" {
        runoncepath("0:/SaturnAerospace/Telesto/CAPSULE/Abort/abort_s2.ks").
    }
}