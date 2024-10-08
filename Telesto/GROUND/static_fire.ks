// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//  Vehicle Static Fire
// ------------------------


clearscreen.
local _THROT_CONTROL is 1.
LOCAL _CURRENT_FACING IS SHIP:FACING.
_FLIGHT_COMPUTER_INIT().

GLOBAL FUNCTION _FLIGHT_COMPUTER_INIT {
    // Required Files
        runOncePath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/VEHICLE/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/mission_Settings.ks"). // Settings for the mission
        runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // Parts on the vehicle

        global _YES is 0.

        IF exists("0:/Data/Telesto/ship_Thrust.txt") {
        deletePath("0:/Data/Telesto/ship_Thrust.txt").
        log "N/A" to "0:/Data/Telesto/ship_Thrust.txt".
    } 
    // Initialisation
        _DEFINE_SETTINGS(). // Grab settings for the mission
        _DEFINE_COUNTDOWN(). // Grab countdown items
        _DEFINE_TELESTO_S1(). // Parts for S1
        _DEFINE_PAD_PARTS().
        // _DEFINE_TELESTO_S2(). // Parts for S2
        // _DEFINE_TELESTO_SRB(). // Parts for SRB's

        // _VEHICLE_VARIABLES(). // Get launch variables for flight
        
        _VEHICLE_PROPELLANT("Stage 1").
        // _VEHICLE_PROPELLANT("Stage 2").

        _TELESTO_SF_MAIN(_YES).
    
}

GLOBAL function _TELESTO_SF_MAIN {
    parameter _T_TIME.
    local _T is _T_TIME.

    lock throttle to 1.
    until _T >= _SF_DURATION {
        set _T to _T + 0.5.
        log "T+ " + _CLOCK_TIME(_T) to "0:/Data/Telesto/mission_Time.txt". 
        wait 0.5.
        print _CLOCK_TIME(_T).
        log ship:thrust to "0:/Data/Telesto/ship_Thrust.txt".
        wait 0.5.
    }

    lock throttle to 0.

    wait 10.

    _ENGINE_CONTROL("Stage 1", "shutdown").
    for p in _GND_DELUGE {
        local m is p:getmodule("ModuleEnginesFX").
        m:doevent("Shutdown Engine").
    }
    // Startup - COMPLETE and WORKING
    // Full duration - COMPLETE AND WORKING
    // log max thrust produced - TO TEST
    // log begin and end fuel levels. - TO ADD
    wait 1.
    shutdown.
}