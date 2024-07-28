        runOncePath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/mission_Settings.ks"). // Settings for the mission
        runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // Parts on the vehicle
        _DEFINE_SETTINGS(). // Grab settings for the mission
        _DEFINE_COUNTDOWN(). // Grab countdown items
        // _DEFINE_COMPUTERS(). // CPU Cores
        // _DEFINE_PAD_PARTS(). // Pad parts
        _DEFINE_TELESTO_S1(). // Stage 1 parts
        _DEFINE_TELESTO_S2(). // Stage 2 parts
        // _DEFINE_TELESTO_SRB(). // SRB Parts
        _DATAOUTPUTCHECKER().
clearscreen.


until false {
    if _COUNTDOWN_TYPE = "Launch" {_DATALOGGING().}

    _PRINT_TELEM().

    wait 0.25. // 4 Updates each second
}

GLOBAL FUNCTION _PRINT_TELEM { // Show things on the screen for debug
   _VEHICLE_PROPELLANT("Stage 1").
   _VEHICLE_PROPELLANT("Stage 2").
   // What to decide to put in here.
   // Different types of debug menues depending on stage of flight?
   
   // Current Launch Status (If in flight, on the ground or in space.)
   // current fuel load DONE
   // altitude DONE, speed DONE

    print "---------- Telesto Telemetry Panel ----------" at (0,4).
    print "Throttle: " + throttle * 100 + "%" + "         " at (0,5).
    print "T+ " + _CLOCK_TIME(missionTime) at (0,6).
    print "Countdown Type: " + _COUNTDOWN_TYPE at (0,7).
    print "Vehicle Altitude: " + floor(ship:altitude / 1000, 1) + " KM" + "         " at (0,8). 
    print "Vehicle Speed: " + floor(ship:airspeed * 3.6) + " KM/H" + "         " at (0,9).
    print "---------- Vehicle Orbital Details ----------" at (0,10).
    print "Vehicle Apogee: " + floor(ship:apoapsis / 1000, 1) + " KM" + "         " at (0,11).
    print "Time to Apogee: " + _CLOCK_TIME(eta:apoapsis) + "         " at (0,12).
    print "Vehicle Perigee: " + floor(ship:periapsis / 1000, 1) + " KM" + "         " at (0,13).
    print "Time to Periapsis: " + _CLOCK_TIME(eta:periapsis) + "         " at (0,14).
    print "---------- Stage 2 Propellant Levels ----------" at (0,15).
    print "CH2: " + floor(_S2_PROPELLANT_CH2_AMOUNT) + " L" + "         " at (0,16).
    print "OX: " + floor(_S2_PROPELLANT_OX_AMOUNT) + " L" + "         " at (0,17).
    print "Overall: " + _PROPELLANT_PERCENTAGE("Stage 2") + "         " at (0,18).
    print "---------- Stage 1 Propellant Levels ----------" at (0,19).
    print "LqdFuel: " + floor(_S1_PROPELLANT_LF_AMOUNT) + " L" + "         " at (0,20).
    print "OX: " + floor(_S1_PROPELLANT_OX_AMOUNT) + " L" + "         " at (0,21).
    print "Overall: " + _PROPELLANT_PERCENTAGE("Stage 1") + "         " at (0,22).
}


GLOBAL FUNCTION _DATAOUTPUTCHECKER {
    IF exists("0:/Data/Telesto/mission_Time.txt") { // Checks if mission time exists
        deletePath("0:/Data/Telesto/mission_Time.txt").
        log "N/A" to "0:/Data/Telesto/mission_Time.txt".
    }

    IF exists("0:/Data/Telesto/vehicle_Speed.txt") { // Checks if vehicle speed text file exists
        deletePath("0:/Data/Telesto/vehicle_Speed.txt").
        log "N/A" to "0:/Data/Telesto/vehicle_Speed.txt".
    } 

    IF exists("0:/Data/Telesto/vehicle_Alt.txt") { // Checks if vehicle altitude file exists
        deletePath("0:/Data/Telesto/vehicle_Alt.txt").
        log "N/A" to "0:/Data/Telesto/vehicle_Alt.txt".
    }


    LOCAL _BASE_DIRECTORY is "0:/Data/Telesto/Flights". // Sets the base directory to this position

        IF NOT(EXISTS(_BASE_DIRECTORY)) {CREATEDIR(_BASE_DIRECTORY).} // If the folder doesn't exist, make it
        CD(_BASE_DIRECTORY). // Set the default directory as this

        LIST FILES in _BASE_DIRECTORY_FILE_LIST.

        GLOBAL _THIS_FLIGHT_NUMBER is _BASE_DIRECTORY_FILE_LIST:length + 1. // Add 1 to the flight number as the past is obviously lower
        LOCAL _FLIGHT_LOG_DIRECTORY is _BASE_DIRECTORY + "/Flight " + _THIS_FLIGHT_NUMBER. // Create folder with flight number

        IF NOT(EXISTS(_FLIGHT_LOG_DIRECTORY)) {CREATEDIR(_FLIGHT_LOG_DIRECTORY).} // If it doesnt exist, make it

    // Now create files that'll be inside each flight
        GLOBAL _DATA_DIRECTORY is _FLIGHT_LOG_DIRECTORY + "/FLIGHT_" + _THIS_FLIGHT_NUMBER + "_DATA.CSV".
        LOG "FLIGHT: " + _THIS_FLIGHT_NUMBER + " DATA LOGGING SHEET" to _DATA_DIRECTORY.
        log "Mission Time, Ship Altitude, Ship Latitude, Ship Longitude, Ship Apoapsis, Ship Periapsis, Ship Mass, Ship Maxthrust, Ship Throttle" to _DATA_DIRECTORY.

        SET _INIT_START_TIME to TIME. // Sets start time to ksp time
}


GLOBAL FUNCTION _DATALOGGING {
    log floor(ship:airspeed * 3.6) to  "0:/Data/Telesto/vehicle_Speed.txt". // Speed in km/h
    log floor(ship:altitude / 1000, 1) to "0:/Data/Telesto/vehicle_alt.txt". // Altitude in km
        
        if missionTime > 0 {
            log "T+" + _CLOCK_TIME(missionTime) to "0:/Data/Telesto/mission_Time.txt". // Logs T+ time

            log _CLOCK_TIME(missionTime) + ", " + round(ship:altitude, 4) + ", " + round(ship:latitude, 4) + ", " + round(ship:longitude, 4) + ", " + round(ship:apoapsis, 4) + ", " + round(ship:periapsis, 4) + ", " + round(ship:mass, 4) + ", " + round(ship:maxthrust) + ", " + throttle * 100 to _DATA_DIRECTORY. // Log to CSV
        }
 // 39x17
    wait 0.075. 
}