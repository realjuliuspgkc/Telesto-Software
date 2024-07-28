clearscreen.
local _THROT_CONTROL is 1.
LOCAL _CURRENT_FACING IS SHIP:FACING.
_FLIGHT_COMPUTER_INIT().

GLOBAL FUNCTION _FLIGHT_COMPUTER_INIT {
    // Required Files
        runOncePath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/VEHICLE/functions.ks"). // Functions for the vehicle
        runOncePath("0:/SaturnAerospace/Telesto/CAPSULE/functions.ks"). // Functions for the capsule
        runOncePath("0:/SaturnAerospace/Telesto/mission_Settings.ks"). // Settings for the mission
        runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // Parts on the vehicle

        set steeringManager:maxstoppingtime to 0.01. // Smooth & Controlled Movement
        set steeringManager:rollts to 2. // Smooth Roll
        set config:ipu to 2000. // CPU Speed
        set _ABT_TWR to false.


    // Initialisation
        _DEFINE_SETTINGS(). // Grab settings for the mission
        _DEFINE_COUNTDOWN(). // Grab countdown items
        _DEFINE_TELESTO_CAPSULE().

        _VEHICLE_VARIABLES(). // Get launch variables for flight

        _EVT_LOGGING_PRECHECK("Launch").
        log "Capsule" to _EVT_DATA_DIRECTORY.
    // Process
            wait 5.
            lock steering to prograde.
            rcs on.
            print "Getting away from S2" at (0,1).
            set ship:control:fore to 0.5.
            wait 10.
            set ship:control:fore to 0.
            rcs off.

            until false {
                wait 1.
                print "Waiting for more instructions" at (0,1).
            }
}