clearscreen.
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

        _EVT_LOGGING_PRECHECK("Capsule").
        log "Capsule" to _EVT_DATA_DIRECTORY.
    // Process
    if _VESSELTARGET = true {local _TGT is _TARGET_SPACECRAFT.} else {}
        lock steering to prograde.
        ag6 off.
        wait 5.
        rcs on.
        print "Getting away from S2" at (0,1).
        set ship:control:fore to 1.
        wait 10.
        set ship:control:fore to 0.
        rcs off.

        until ag6 {
            wait 1.
            print "Waiting for more instructions" at (0,1).
        }
    
    // Put ship orbit to the final orbit (SHOULD BE THE TARGET ORBIT!!)
        until ship:apoapsis >= _FINAL_APOGEE and ship:periapsis >= _FINAL_PERIGEE {
            _OMT_ENABLE(true).
            lock steering to prograde.
            // Check if target orbit is the same as the set apogee and perigee. if not, set the variables to target orbit.
            if _TGT:orbit:apoapsis <> _FINAL_APOGEE {set _FINAL_APOGEE to _TGT:orbit:apoapsis.} // idk if this is going to work..
            if _TGT:orbit:periapsis <> _FINAL_PERIGEE {set _FINAL_PERIGEE to _TGT:orbit:periapsis.} // ^^
            
            // Burn Calculations.
            

            // Burn Control
            until eta:apoapsis < 5 {
                if ship:apoapsis < _FINAL_APOGEE {rcs on. set ship:control:fore to 0.5.}
                else if ship:apoapsis > _FINAL_APOGEE + 100 {rcs on. set ship:control:fore to -0.5.}
                else if ship:apoapsis > _FINAL_APOGEE and ship:apoapsis < _FINAL_APOGEE + 100 {set ship:control:fore to 0. rcs off.}
            }
            rcs on.
            set ship:control:fore to 1.

            until ship:periapsis >= _FINAL_PERIGEE - 500 {
                if ship:periapsis > body:atm:height {set ship:control:fore to 1.}
                
                wait 0.1.
            }

            set ship:control:fore to 0.
            _OMT_ENABLE(false).

            if ship:periapsis >= _FINAL_PERIGEE - 150 {rcs on. set ship:control:fore to 0.5.}
            else if ship:periapsis >= _FINAL_PERIGEE - 50 {rcs on. set ship:control:fore to 0.2.}
            else if ship:periapsis >= _FINAL_PERIGEE {set ship:control:fore to 0. rcs off.}
        }




        if hasTarget = false {set target to _TARGET_SPACECRAFT.}

    // Rendezvous with Rhea
        if ship:periapsis < _PARK_ORBIT - 100 {
            _CATCH_ORBIT().
        }
        _match_align().
        _hoffmann_raise().
        _hoffmann_circularise().

    // Reach Rhea
        _REDUCE_RELATIVE_VELOCITY(100). // Reduces velocity relative to station 
        _TRANSLATE_TO_STATION(5000, 20, 40). // Now move toward the station 
        _TRANSLATE_TO_STATION(2500, 15, 10). // Now move slower as we get closer
        _TRANSLATE_TO_STATION(170, 8.5, 10). // Finally move to the physics range of the target

    // Dock with Rhea
        global _CALYPSO_DOCKING_PORT is _CC_DCK. // Assign docking port to the variable set on launch
        global _STATION_DOCKING_PORT is target:partstagged("APAS_VAST2")[0]. // Get the station's part for docking [APAS_FRONT] [APAS_BACK]

        _CALYPSO_MOVE_TO_DOCK(50, 2). // Close to 50m at 2m/s
        _CALYPSO_HOLD_POINT(). // Hold at 50m

        LOCK STEERING TO LOOKDIRUP(ship:prograde:forevector, ship:body:position). // Panels Up & point to port

        _NARVI_MOVE_TO_DOCK(25, 1). // Close to 25m at 1m/s
        _NARVI_HOLD_POINT(). // Hold at 25m
        _NARVI_MOVE_TO_DOCK(10, 0.8). // Close to 10m at 0.8m/s
        _NARVI_HOLD_POINT(). // Hold at 10m
        _NARVI_MOVE_TO_DOCK(0.5, 0.4). // Close to dock with station at 0.4m/s

        set ship:control:neutralize to true.
        wait 4.
        unlock steering.
        unlock throttle.
}

local function _OMT_ENABLE {
    parameter _TOGGLE.
    if _TOGGLE = true {
        for p in _CAP_OMT {
            if p:modules:contains("ModuleEnginesFX"). {
                local m is p:getmodule("ModuleEnginesFX").
                for a in m:allactionnames {
                    if a:contains("Activate Engine") {m:doaction(a, true).}
                }

            }
        }
    } else if _TOGGLE = false {
        for p in _CAP_OMT {
            if p:modules:contains("ModuleEnginesFX"). {
                local m is p:getmodule("ModuleEnginesFX").
                for a in m:allactionnames {
                    if a:contains("Shutdown Engine") {m:doaction(a, true).}
                }

            }
        }
    }
}

LOCAL FUNCTION _CATCH_ORBIT { // Checks the current orbit and where the station is to catch it (also boosts periapsis)
    wait 15. // Settling time to move away from the Telesto Vehicle

    LOCK STEERING TO LOOKDIRUP(ship:retrograde:forevector, ship:body:position). // Locks retrograde with panels up now, rather than down on launch
    
    UNTIL eta:apoapsis < 5 {
        IF ship:apoapsis < _PARK_ORBIT {rcs on. set ship:control:fore to -0.5.} // To get to target apogee (has more powerful thrusters as it's facing back)
        ELSE IF ship:apoapsis > _PARK_ORBIT + 100 {rcs on. set ship:control:fore to 1.} // If we're too high above apogee (less power thrusters facing back)
        ELSE IF ship:apoapsis > _PARK_ORBIT and ship:apoapsis < _PARK_ORBIT + 100 {set ship:control:fore to 0. rcs off.} // When at target apogee

        wait 0.
    }

    rcs on.
    set ship:control:fore to -1. // Start burning rearward to raise the periapsis to the intended altitude

    UNTIL ship:periapsis >= _PARK_ORBIT - 500 {
        IF ship:periapsis > body:atm:height {set ship:control:fore to -1.} // Lower thrust for final part of the burn

        wait 0.
    }

    set ship:control:fore to 0. // Periapsis should now be raised 
    rcs off.
}

LOCAL FUNCTION _MATCH_ALIGN { // Align the AN/DN of the orbit to be 0 or close to that
    wait 30.

    IF abs(AngToRAN()) > abs(AngToRDN()) { // Plane Correction based on angle to ascending / descending nodes
        set _PLANECORRECT TO 1.
    } ELSE {
        set _PLANECORRECT to -1.
    }

    set _ALIGNMENT_NODE to node(time:seconds + _TIMETONODE(), 0, (_NODEPLANECHANGE() * _PLANECORRECT), 0). // Creates a node for aligning the orbit with the target
    add _ALIGNMENT_NODE. // Adds the node to the current craft

    _EXECUTE_NODE(13, true, "REAR"). // This executes the maneuver, 13 = thrust of RCS, true = using rcs, "rear" = facing position
    remove _ALIGNMENT_NODE. // Now remove the node from the list
}

LOCAL FUNCTION _HOFFMANN_RAISE { // Raise the orbit to intercept the target
    wait 30. // Settling time from the last maneuver

    set _HOHMAN_RAISE_NODE to node(time:seconds + _PHASEANGLE(), 0, 0, _HOHMANN("RAISE")). // Creates a node for the raise maneuver
    add _HOHMAN_RAISE_NODE. // Adds the node to the craft

    _EXECUTE_NODE(13, true, "FORE"). // This executes the maneuver, 13 = thrust of RCS, true = using rcs, "rear" = facing position
    remove _HOHMAN_RAISE_NODE. // Removes node from list
}

LOCAL FUNCTION _HOFFMANN_CIRCULARISE { // Circularise the orbit when at the apogee (close to intercept)
    wait 30. // Settle time for the raise burn

    set _HOHMAN_CIRCULARISE_NODE to node(time:seconds + eta:apoapsis, 0, 0, _HOHMANN("CIRC")). // Creates a node to raise periapsis as craft reaches apogee
    add _HOHMAN_CIRCULARISE_NODE. // Adds the node to the list

    _EXECUTE_NODE(13, true, "REAR"). // This executes the maneuver, 13 = thrust of RCS, true = using rcs, "rear" = facing position
    remove _HOHMAN_CIRCULARISE_NODE. // Remove the node from the list
}