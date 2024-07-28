clearscreen.
print "Waiting for message - Boosters".

until false {
    wait until not core:messages:empty. // Waits until the core recieves a message
    set _MSGRECIEVED to core:messages:pop. // Assigns variable to message recieved
    set _DECODEDMSG to _MSGRECIEVED:content. // Stores message in a decoded format

    IF _DECODEDMSG = "Seperate" {
        runOncePath("0:/SaturnAerospace/Telesto/BOOSTER/flight.ks"). // Runs path of recieved message
    }
}