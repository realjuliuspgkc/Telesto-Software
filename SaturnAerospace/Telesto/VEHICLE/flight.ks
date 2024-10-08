// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//     Vehicle Flight
// ------------------------

clearscreen.
local _THROT_CONTROL is 1.
LOCAL _CURRENT_FACING IS SHIP:FACING.
_FLIGHT_COMPUTER_INIT().

local FUNCTION _FLIGHT_COMPUTER_INIT {
    // Required Files
        runOncePath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/VEHICLE/functions.ks"). // Vehicle Functions
        runOncePath("0:/SaturnAerospace/Telesto/mission_Settings.ks"). // Settings for the mission
        runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // Parts on the vehicle

        set steeringManager:maxstoppingtime to 5.
        set steeringManager:rollts to 10.
        set config:ipu to 2000.
        set kuniverse:defaultloaddistance:flying:unload to 30000.

    // Initialisation
        _DEFINE_COMPUTERS().
        _DEFINE_SETTINGS(). // Grab settings for the mission
        _DEFINE_COUNTDOWN(). // Grab countdown items
        _DEFINE_TELESTO_S1(). // Parts for S1
        _DEFINE_TELESTO_S2(). // Parts for S2
        _DEFINE_TELESTO_SRB(). // Parts for SRB's
        _DEFINE_TELESTO_CAPSULE().

        _VEHICLE_VARIABLES(). // Get launch variables for flight

        _EVT_LOGGING_PRECHECK("Launch").
        log "FLIGHT" to _EVT_DATA_DIRECTORY.
        
        _VEHICLE_PROPELLANT("Stage 1").
        _VEHICLE_PROPELLANT("Stage 2").
        _VEHICLE_PROPELLANT("SRB").
    // Process
        _TELESTO_FLIGHT_MAIN(). // Fly The Rocket
}



LOCAL FUNCTION _TELESTO_FLIGHT_MAIN {
    // Stage 1 
        _TOWER_CLEAR(). // Clear the tower and fly up to a specific speed
        _BOOSTER_GUIDANCE(). // Pitches over the entire stack, when SF reaches < 10 it seperates.

    // Stage 2 
        _INITIAL_GUIDANCE(). // Guide initially to push our apogee higher
        _ORBITAL_INSERTION(). // Finalise orbit by raising periapsis if needed
        _ORBIT_TOUCHUP().
        _CAPSULE_DEPLOY().
        // _DEORBIT().
}



// --------------------
//   MAIN S1 SECTION 
// --------------------

LOCAL FUNCTION _TOWER_CLEAR { // Clear the tower
log "Tower Clear Guidance at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
print "S1 Tower Clear" at (0,1).
    LOCK THROTTLE TO 1. // Full Throttle
    LOCK STEERING TO _CURRENT_FACING. // Lock UP without roll

    WAIT UNTIL SHIP:VERTICALSPEED > _PITCHOVER_START_SPEED. // Wait for our verticalspeed to reach this before gravity turn
}

LOCAL FUNCTION _BOOSTER_GUIDANCE { // Begin guidance/pitchover
    log "S1 Guidance Begin at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    print "S1 Guidance Begin" at (0,1).
    _VEHICLE_PROPELLANT("Stage 1").
    SET _CURRENT_PITCH TO 90.
    UNTIL _CURRENT_PITCH <= _PITCHOVER_FINAL_ANGLE + 0.1 and ship:LiquidFuel < 10 {
            _Steering_Control("S1").

            if ship:SolidFuel < 450 and _SRB_ATTACHED = true {
                SET _CURRENT_FACING TO SHIP:FACING.
                LOCK STEERING TO _CURRENT_FACING.

                WAIT 2. // Settle the steering

                _SEPARATE_SRBS(). // Separate the SRB's
                log "SRB Seperation at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
                set _SRB_ATTACHED to false.

                WAIT 2. // Settling Time
            }


            // Narvi Abort
                if ag4 {
                    _ENGINE_CONTROL("Stage 1", "shutdown").

                    IF _VEHICLE_CONFIGURATION = "CAPSULE" {
                        _CAP_CORE:SENDMESSAGE("ABORT S1").
                    }

                    wait 1.
                    _FLIGHTTERMINATION("STAGE 1"). // Sends FTS command to stage 1
                }

        lock steering to heading(_Heading_Control, _Pitch_Control, 90).
        lock throttle to _THROT_CONTROL.
        SET _CURRENT_PITCH TO 90 - vAng(ship:up:forevector, ship:facing:forevector).
    }
    _STAGE_SEPARATION().
}
// ---------------
//   STAGE SEP 
// ---------------

LOCAL FUNCTION _STAGE_SEPARATION { // get rid of S1
log "Stage Seperation at: " + _CLOCK_TIME(missionTime) + " " + round(ship:altitude, 2) + " M" to _EVT_DATA_DIRECTORY.
    print "Stage Sep" at (0,1).
    SET _CURRENT_FACING TO SHIP:FACING.
    LOCK STEERING TO _CURRENT_FACING. 

    lock throttle to 0.

    wait 2.

    FOR P in _S_SEP {
        if P:Modules:contains("ModuleEngines") {
            local m is p:getmodule("ModuleEngines").
            for a in m:allactionnames() {
                if a:contains("activate engine") {m:doaction(a, true).}
            }
        }
    }
    
    WAIT 0.1.

    _S1_INTER:getmodulebyindex(0):doevent("decouple").

    
    wait 2.5.
    
    _ENGINE_CONTROL("Stage 2", "startup").
    lock throttle to 0.1.

    WAIT 2.

    lock throttle to 1.
}

// --------------------
//   MAIN S2 SECTION 
// --------------------

LOCAL FUNCTION _INITIAL_GUIDANCE { // Initial S2 Guidance
log "S2 Guidance Begin at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    local _G_FORCE_LIMIT is _G_FORCELIMIT * 10. 
    print "S2 Guidance Begin" at (0,1).
    set steeringManager:maxstoppingtime to 0.5.
    set steeringManager:rollts to 20.

    lock steering to _CURRENT_FACING.
    until ship:apoapsis >= body:atm:height - 4000 {wait 0.5.}

    _ABORT_TWR_DELETUS().

    until ship:apoapsis >= _PARK_ORBIT - 2500 and ship:periapsis > body:atm:height - 2000 {
        local _THROT_CONTROL is (_G_FORCE_LIMIT * ship:mass / (ship:maxThrust + 0.1) * 100).
        _Steering_Control("S2"). // begins the guidance

        _DEPLOY_FAIRINGS("Payload"). // Gets rid of fairings cuz no longer needed.

        // Steering Maximums
            if _Pitch_Control < -7.5 {set _Pitch_Control to -7.5.} // Lowest pitch
            if _Pitch_Control > 15 {set _Pitch_Control to 15.} // Heighest pitch
            if ship:apoapsis < body:atm:height and _Pitch_Control < -1 {set _Pitch_Control to -1.}
            if ship:apoapsis > body:atm:height and ship:periapsis > 0 {set _Pitch_Control to 0.}
            if ship:verticalSpeed < 0 and alt:radar < body:atm:height {set _Pitch_Control to -ship:verticalspeed.}

        // Loop Break Scenarios
            if ship:apoapsis >= _PARK_ORBIT + 1500 and ship:periapsis >= body:atm:height - 25000 {
                print "BROKE LINE 155" at (0,4).
                log "Loop break scenario on line 155 broke at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
                break.}
            if _PARK_ORBIT > 500000 and ship:apoapsis >= _PARK_ORBIT - 10000 {
                print "BROKE LINE 159" at (0,4).
                log "Loop break scenario on line 159 broke at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
                break.}


        // Capsule abort to be added here

        // Throttle & steering apparently?
            _INCLINE_MANAGER(3).
            lock steering to heading(_Heading_Control, _Pitch_Control, 0). // Steer the damn rocket.

            if ship:apoapsis <= _PARK_ORBIT - 20000 {lock throttle to _THROT_CONTROL.}
            if ship:apoapsis >= _PARK_ORBIT - 20000 and ship:periapsis >= _PARK_ORBIT - 100000 {set config:ipu to 2000. lock throttle to _THROT_CONTROL - 40.}

        wait 0.1. // waiting for this 0.1 of a second to reduce lag apparently.

    }

    set config:ipu to 1000.
    lock throttle to 0. // SECO
    print "SECO" at (0,2).
    log "SECO at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    wait 5.

}

LOCAL FUNCTION _ORBITAL_INSERTION { // S2 Orbital Insertion
    log "Orbital Insertion Begin at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    print "Orbital Insertion" at (0,1).

    local maxthrot is 0.
    
    lock steering to prograde.

    until eta:apoapsis <= 60 {

        if ship:apoapsis < _PARK_ORBIT + 10 and eta:apoapsis > 60 {rcs on. set ship:control:fore to 0.5. print "Raising Apoapsis" at (0,7).}
        else if ship:apoapsis >= _PARK_ORBIT + 50 and eta:apoapsis > 60 {rcs on. set ship:control:fore to -0.5. print "Lowering Apoapsis" at (0,7).}
        else if ship:apoapsis >= _PARK_ORBIT + 10 and ship:apoapsis < _PARK_ORBIT + 50 and eta:apoapsis > 60 {set ship:control:fore to 0. rcs off. print "Stopping Corrections" at (0,7).}
        else if ship:apoapsis >= _PARK_ORBIT + 10 and ship:periapsis >= _PARK_ORBIT + 10 {set ship:control:fore to 0. rcs off.}

        wait 0.1.
    }
    until eta:apoapsis <= 15 and ship:periapsis = _PARK_ORBIT {
        if ship:periapsis <= _PARK_ORBIT - 20000 {set maxthrot to 0.7.}
        else if ship:periapsis <= _PARK_ORBIT - 500 {set maxthrot to 0.4.}
        else if ship:periapsis <= _PARK_ORBIT - 150 {set maxthrot to 0.3.}
        else if ship:periapsis <= _PARK_ORBIT - 150 {set maxthrot to 0.2.}
        else if ship:periapsis <= _PARK_ORBIT - 50 {set maxthrot to 0.1.}
        else if ship:periapsis >= _PARK_ORBIT {set maxthrot to 0.}
    }
    
    set ship:control:fore to 0.
    print "Apoapsis is ok.. the loop has ended so." at (0,5).
    log "Apoapsis is set at: " + round(ship:apoapsis, 2) + " at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    
    lock throttle to maxthrot.
    
    until ship:periapsis >=(_PARK_ORBIT - 1000) {
        if ship:periapsis >= _PARK_ORBIT - 10000 {lock throttle to 0.4.}

        wait 0.
    }
    print "Periapsis is ok.. the loop has ended so." at (0,5).
    log "Periapsis is set at: " + round(ship:periapsis, 2) + " at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.

    lock throttle to 0.
    log "Orbital Insertion finished and at a final orbit of: " + "APOAPSIS: " + round(SHIP:apoapsis, 2) + "KM" + " PERIAPSIS: " + round(ship:periapsis, 2) + "KM" + " at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    wait 5.

    set ship:control:fore to 0.
    rcs off.
    _ENGINE_CONTROL("Stage 2", "shutdown").
}

local function _ORBIT_TOUCHUP {
    until ship:periapsis >= _PARK_ORBIT + 5 {
        if ship:periapsis < _PARK_ORBIT + 10 and eta:periapsis > 60 {rcs on. set ship:control:fore to 0.5. print "Raising Periapsis" at (0,7).}
        else if ship:periapsis >= _PARK_ORBIT + 50 and eta:periapsis > 60 {rcs on. set ship:control:fore to -0.5. print "Lowering Periapsis" at (0,7).}
        else if ship:periapsis >= _PARK_ORBIT + 10 and ship:periapsis < _PARK_ORBIT + 50 and eta:periapsis > 60 {set ship:control:fore to 0. rcs off. print "Stopping Corrections" at (0,7).}

        wait 0.1.
        log "Periapsis has been touched up to: " + round(ship:periapsis, 2) + " at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    }
    until ship:apoapsis >= _PARK_ORBIT + 5 {
        if ship:apoapsis < _PARK_ORBIT + 10 and eta:apoapsis > 60 {rcs on. set ship:control:fore to 0.5. print "Raising Apoapsis" at (0,7).}
        else if ship:apoapsis >= _PARK_ORBIT + 50 and eta:apoapsis > 60 {rcs on. set ship:control:fore to -0.5. print "Lowering Apoapsis" at (0,7).}
        else if ship:apoapsis >= _PARK_ORBIT + 10 and ship:apoapsis < _PARK_ORBIT + 50 and eta:apoapsis > 60 {set ship:control:fore to 0. rcs off. print "Stopping Corrections" at (0,7).}
        wait 0.1.
        log "Apoapsis has been touched up to: " + round(ship:periapsis, 2) + " at: " + _CLOCK_TIME(missionTime) to _EVT_DATA_DIRECTORY.
    }
}

LOCAL FUNCTION _CAPSULE_DEPLOY {
    _MESSAGE_SENDER("CAPSULE", "Init").
    _DEPLOY_FAIRINGS("Capsule").
    wait 5.
    _S2_PAYL:getmodule("ModuleDecouple"):doaction("Decouple", true).
}

local function _DEORBIT {

}