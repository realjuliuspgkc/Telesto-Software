// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//   Vehicle Functions
// ------------------------

GLOBAL FUNCTION _VEHICLE_VARIABLES { // Holds important details and variables for flight and ascent
    // Stage 1
        SET _PITCHOVER_START_SPEED TO 100. 
        SET _PITCHOVER_FINAL_ANGLE TO -1.
        SET _PITCHOVER_FINAL_ALTITUDE TO 52500.
        SET _PITCHOVER_CUTOFF_PROP_PERCENT TO 1.
        set _SRB_ATTACHED to true.
        if _VEHICLE_CONFIGURATION = "Capsule" {
            set _FAIRINGS_ATTACHED to false.
        } else {
        set _FAIRINGS_ATTACHED to true.
        }
        set _FAIRING_DEPLOYALTITUDE to 70000.
        set _FAIRING_DEPLOYPRESSURE to 2.0.


    // Boosters


    // Stage 2 
}






// ACTIONS

GLOBAL FUNCTION _SEPARATE_SRBS {
    for p in _SRB_SEP {
        if P:Modules:contains("ModuleEnginesFX") {
            local m is p:getmodule("ModuleEnginesFX").
            for a in m:allactionnames() {
                if a:contains("activate engine") {m:doaction(a, true).}
            }
        }
    }
    wait 0.5.
    FOR P in _SRB_DECOUPLER {
        IF P:MODULES:CONTAINS("ModuleAnchoredDecoupler") { // If the parts contain the module
            LOCAL M is P:getmodule("ModuleAnchoredDecoupler"). // Get the module
            FOR A in M:ALLACTIONNAMES() { // For each action in action names
                if A:CONTAINS("Decouple") {M:DOACTION(A, true).} // If the action names contain decoupling, decouple fairings
            }
        }
    }
    
}

global function _Steering_Control {
    parameter _STAGE.

    if _Stage = "S1" {
        set _Heading_Control to _LAUNCH_AZIMUTH(_INCLINE_TARGET, _APOGEE_TARGET).
        set _Pitch_Control to max(_PITCHOVER_FINAL_ANGLE, 90 * (1 - ship:altitude / _PITCHOVER_FINAL_ALTITUDE)).
    } else if _Stage = "S2" {
        if _APOGEE_TARGET > body:atm:height + 20000 {
            set _apoapsisoffset to ship:apoapsis - body:atm:height.
        } else {
            set _apoapsisoffset to ship:apoapsis - _APOGEE_TARGET.
        }

        set _halvedata to 15 - eta:apoapsis.

        set _Heading_Control to _LAUNCH_AZIMUTH(_INCLINE_TARGET, _APOGEE_TARGET).
        set _Pitch_Control to (_halvedata * 2) + ((_apoapsisoffset / 5000) * 10).
    }
}


global function _DEPLOY_FAIRINGS {
    parameter _CONFIG.

    if _CONFIG = "Capsule" {
        FOR P in _S2_FAIRING {
                LOCAL M is P:getmodulebyindex(0). // Get the module
                FOR A in M:ALLACTIONNAMES() { // For each action in action names
                    if A:CONTAINS("deploy") {M:DOACTION(A, true). set _FAIRINGS_ATTACHED to false.} // If the action names contain decoupling, decouple fairings
                }
        }
    } else if _CONFIG = "Payload" {
        IF ship:altitude >= _FAIRING_DEPLOYALTITUDE and ship:dynamicpressure <= _FAIRING_DEPLOYPRESSURE and _FAIRINGS_ATTACHED { // Checks to see the current parameters
            FOR P in _S2_FAIRING {
                    LOCAL M is P:getmodulebyindex(0). // Get the module
                    FOR A in M:ALLACTIONNAMES() { // For each action in action names
                        if A:CONTAINS("deploy") {M:DOACTION(A, true). set _FAIRINGS_ATTACHED to false.} // If the action names contain decoupling, decouple fairings
                    }
            }
        }
    }
}


global function _ABORT_TWR_DELETUS {
    _CAP_ABORT:getmodulebyindex(4):doaction("jettison tower", true).
}

GLOBAL FUNCTION _ORBITALVELOCITYPERIGEE { // _TARGETVEL (Target apogee and perigee)
    parameter _APOGEE, _PERIGEE.

    local _SEMIMAJORAXIS is body:radius + (_APOGEE + _PERIGEE) / 2.
    local _V is (body:mu * ((2 / (_PERIGEE)) - (1 / _SEMIMAJORAXIS))) ^ 0.5.

    return _V.
}

GLOBAL FUNCTION _ORBITALVELOCITYAPOGEE { // _CURRENTVEL (current apogee and perigee)
    parameter _APOGEE, _PERIGEE.

    local _SEMIMAJORAXIS is body:radius + (_APOGEE + _PERIGEE) / 2.
    local _V is (body:mu * ((2 / (_APOGEE)) - (1 / _SEMIMAJORAXIS))) ^ 0.5.

    return _V.
}

GLOBAL FUNCTION _ORBITALVELOCITY {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude.
    
    set r1 to r1+body:radius.
    set r2 to r2+body:radius.
    set r3 to r3+body:radius.

    local _a is (r1+r2)/2. // _SEMIMAJORAXIS
    local __V is (body:mu * ((2 / (r3)) - (1/_a))) ^ 0.5.
    return __V.
}

