// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//   Functions Ground
// ------------------------

// VEHICLE PART & SETTING FUNCTIONS

GLOBAL FUNCTION _DEFINE_SETTINGS {
    SET SHIP:NAME TO _MISSION_SETTINGS["MISSION NAME"].

    // The apogee & perigee need to be multiplied by 1000 if you want to use km instead of m for the settings
    GLOBAL _FINAL_APOGEE TO _MISSION_SETTINGS["APOGEE"] * 1000.
    GLOBAL _FINAL_PERIGEE TO _MISSION_SETTINGS["PERIGEE"] * 1000.
    GLOBAL _INCLINE_TARGET TO _MISSION_SETTINGS["INCLINATION"].

    GLOBAL _VEHICLE_CONFIGURATION TO _MISSION_SETTINGS["ROCKET CONFIG"]. 
    GLOBAL _COUNTDOWN_TYPE TO _MISSION_SETTINGS["COUNTDOWN TYPE"].

    if _MISSION_SETTINGS["Target Vessel"] = "None" {
        global _VESSELTARGET to false.
    } ELSE {
        global _VESSELTARGET to true.

        if _MISSION_SETTINGS["Target Vessel"] = "Other" {
            global _TARGET_SPACECRAFT to _MISSION_SETTINGS["Target Vessel"].
        } else {
            global _TARGET_SPACECRAFT to vessel(_MISSION_SETTINGS["Target Vessel"]).
        }
    }
    
    GLOBAL _DEBUG_MENU_ACTIVE TO _MISSION_SETTINGS["DEBUG SHOW"].

    global _G_FORCELIMIT to _EXTRA["G-Force Limit"].
    global _PARK_ORBIT to _EXTRA["Parking Orbit"] * 1000.

    global _INCLINE_CORRECTION is 0.
    global _PROGRADE_HEAD is _COMPASS_FOR(). 
    global _FUEL_VALVE is false.
}

GLOBAL FUNCTION _DEFINE_COUNTDOWN {
    // Countdown Start Decision
    if _COUNTDOWN_TYPE = "Launch" {
        IF _COUNTDOWN_EVENTS["COUNTDOWN BEGIN (UNIX)"]["UNIX"] > kuniverse:realworldtime {
            GLOBAL _COUNTDOWN_START TO ROUND(_COUNTDOWN_EVENTS["COUNTDOWN BEGIN (UNIX)"]).
        } ELSE {
            GLOBAL _COUNTDOWN_START TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["COUNTDOWN BEGIN"]).
        }
    } else if _COUNTDOWN_TYPE = "Static Fire" {
        IF _COUNTDOWN_EVENTS["SF COUNTDOWN BEGIN (UNIX)"]["UNIX"] > kuniverse:realworldtime {
            GLOBAL _COUNTDOWN_START TO ROUND(_COUNTDOWN_EVENTS["SF COUNTDOWN BEGIN (UNIX)"]).
        } ELSE {
            GLOBAL _COUNTDOWN_START TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["SF COUNTDOWN BEGIN"]).
        }
    }



    // Launch 
    GLOBAL _COUNTDOWN_CREW_ARM TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["CREW ARM RETRACT"]).
    GLOBAL _COUNTDOWN_FUEL_START TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["FUEL LOADING BEGIN"]).
    GLOBAL _COUNTDOWN_FUEL_STOP TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["FUEL LOADING CLOSEOUT"]).

    GLOBAL _COUNTDOWN_CORE_IGNITION TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["CORE IGNITION"]).


    // Static Fire
    GLOBAL _SF_COUNTDOWN_FUEL_BEGIN TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["FUEL LOADING BEGIN"]).
    GLOBAL _SF_COUNTDOWN_FUEL_STOP TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["FUEL LOADING CLOSEOUT"]).

    GLOBAL _SF_COUNTDOWN_CORE_IGNITION TO _CONVERT_LEXITIME(_COUNTDOWN_EVENTS["IGNITION"]).
    GLOBAL _SF_DURATION TO _COUNTDOWN_EVENTS["SF Duration"].

}

// PARTS

GLOBAL FUNCTION _DEFINE_COMPUTERS {
    GLOBAL _GND_CORE IS ship:partstagged(_PART_TAGS["GND"]["CORE"])[0].
    GLOBAL _S1_CORE IS ship:partstagged(_PART_TAGS["S1"]["S1 CORE"])[0].
    GLOBAL _S2_CORE IS ship:partstagged(_PART_TAGS["S2"]["S2 CORE"])[0].
    global _BOOST_CORE is ship:partstagged(_PART_TAGS["SRB"]["Boost Core"]).
}

GLOBAL FUNCTION _DEFINE_PAD_PARTS {
    GLOBAL _GND_UMBILICAL_LOWER IS ship:partstagged(_PART_TAGS["GND"]["Fuel Umbilical Lower"])[0].
    GLOBAL _GND_UMBILICAL_UPPER IS ship:partstagged(_PART_TAGS["GND"]["Fuel Umbilical Upper"])[0].
    global _GND_PAD is ship:partstagged(_PART_TAGS["GND"]["Pad"])[0].
    global _GND_TWR_VENT is ship:partstagged(_PART_TAGS["GND"]["Tower Vent"]).
    global _GND_CLAMP is ship:partstagged(_PART_TAGS["GND"]["Hold down Clamp"]).
    global _GND_DELUGE is ship:partstagged(_PART_TAGS["GND"]["Pad Deluge"]).
}

GLOBAL FUNCTION _DEFINE_TELESTO_S1 {
    GLOBAL _S1_FUEL_TANK IS ship:partstagged(_PART_TAGS["S1"]["S1 TANK"])[1].
    GLOBAL _S1_INTER IS SHIP:partstagged(_PART_TAGS["S1"]["S1 INTERSTAGE"])[0].
    global _S1_ENG is ship:partstagged(_PART_TAGS["S1"]["S1 Engine"]).
    global _S_SEP is ship:partstagged(_PART_TAGS["S1"]["Stage Seperator Motors"]).
    global _S1_FTS is ship:partstagged(_PART_TAGS["S1"]["S1 FTS"]).
} 

GLOBAL FUNCTION _DEFINE_TELESTO_S2 {
    GLOBAL _S2_FUEL_TANK IS ship:partstagged(_PART_TAGS["S2"]["S2 TANK"])[0].
    GLOBAL _S2_ENG is ship:partstagged(_PART_TAGS["S2"]["S2 ENGINE"]).
    global _S2_FAIRING is ship:partstagged(_PART_TAGS["S2"]["Fairing"]).
    global _S2_FTS is ship:partstagged(_PART_TAGS["S2"]["S2 FTS"]).
    global _S2_PAYL is ship:partstagged(_PART_TAGS["S2"]["S2 Payload"])[0].
    global _CAP_ABORT is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule Abort"])[0].
}

GLOBAL FUNCTION _DEFINE_TELESTO_SRB {
    GLOBAL _SRB_DECOUPLER IS ship:partstagged(_PART_TAGS["SRB"]["Boost Decoupler"]).
    GLOBAL _SRB_SEP is ship:partstagged(_PART_TAGS["SRB"]["Boost Seperation"]).
    GLOBAL _SRB_ENG is ship:partstagged(_PART_TAGS["SRB"]["Boost Engine"]).
    global RHINGE is ship:partstagged(_PART_TAGS["SRB"]["Right Hinge"]).
    global LHINGE is ship:partstagged(_PART_TAGS["SRB"]["Left Hinge"]).
}

GLOBAL FUNCTION _DEFINE_TELESTO_CAPSULE { // Narvi
    global _CAP_CORE is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule Core"])[0].
    global _CAP_BODY is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule Body"]).
    global _CAP_SERVICE is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule Service Bay"]).
    global _CAP_SEP is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule Seperator"]).
    global _CAP_OMT is ship:partstagged(_PART_TAGS["CAPSULE"]["Capsule OMT"])[3].
}

// COUNTDOWN FUNCTIONS

GLOBAL FUNCTION _MANUAL_HOLD_CHECK { // Checks if we are holding or not and stops the count if we do
    IF AG9 {

        AG9 OFF.
        AG6 OFF.

        PRINT "HOLDING COUNT" at (1,2).
        log "HOLD" to "0:/Data/Telesto/mission_Time.txt".
        log "Hold command sent at " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.

        for p in _GND_TWR_VENT { // Stop fueling
            if p:modules:contains("ModuleEnginesFX") {
                local m is p:getmodule("ModuleEnginesFX").
                for a in m:allactionnames() {
                    if a:contains("Shutdown Engine") {m:doaction(a, true).}
                }
            }
        }

        UNTIL AG6 { // until we continue
            IF AG9 { // in the case we want to fully recycle
                log "AG9 has been pressed while in a hold which has aborted this attempt and is now rebooting the CPU at: " + _CLOCK_TIME(_T) + " and at: " + ROUND(kuniverse:realworldtime) + " UNIX" to _EVT_DATA_DIRECTORY.
                AG9 OFF.
                AG6 OFF. 

                REBOOT.
            }

            WAIT 0.5. 

            
        }

        PRINT "             " at (1,2). 
        
        if _T < _COUNTDOWN_FUEL_START and _T > _COUNTDOWN_FUEL_STOP {
            for p in _GND_TWR_VENT { // restart fueling.
                if p:modules:contains("ModuleEnginesFX") {
                    local m is p:getmodule("ModuleEnginesFX").
                    for a in m:allactionnames() {
                        if a:contains("Activate Engine") {m:doaction(a, true).}
                    }
                }
            }
        }
    }
}

GLOBAL FUNCTION _AUTOMATIC_VALIDATION { // Checks if variables / vehicle status is off-nominal for abort
    
}

GLOBAL FUNCTION _PRINT_DEBUG { // Show things on the screen for debug
   _VEHICLE_PROPELLANT("Stage 1").
   _VEHICLE_PROPELLANT("Stage 2").
   // What to decide to put in here.
   // Different types of debug menues depending on stage of flight?
   
   // Current Launch Status (If in flight, on the ground or in space.)
   // current fuel load DONE
   // altitude DONE, speed DONE
    print "---------- Telesto Debug Panel ----------" at (0,6).
    print "Countdown Type: " + _COUNTDOWN_TYPE at (0,7).
    print "Vehicle Altitude: " + floor(ship:altitude / 1000, 1) + " KM" at (0,8). 
    print "Vehicle Speed: " + floor(ship:airspeed * 3.6) + " KM/H" at (0,9).
    print "---------- Vehicle Orbital Details ----------" at (0,10).
    print "Vehicle Apogee: " + floor(ship:apoapsis / 1000, 1) + " KM" at (0,11).
    print "Time to Apogee: " + _CLOCK_TIME(eta:apoapsis) at (0,12).
    print "Vehicle Perigee: " + floor(ship:periapsis / 1000, 1) + " KM" at (0,13).
    print "Time to Periapsis: " + _CLOCK_TIME(eta:periapsis) at (0,14).
    print "---------- Stage 2 Propellant Levels ----------" at (0,15).
    print "CH2: " + floor(_S2_PROPELLANT_CH2_AMOUNT) + " L" at (0,16).
    print "OX: " + floor(_S2_PROPELLANT_OX_AMOUNT) + " L" at (0,17).
    print "Overall: " + _PROPELLANT_PERCENTAGE("Stage 2") at (0,18).
    print "---------- Stage 1 Propellant Levels ----------" at (0,19).
    print "LqdFuel: " + floor(_S1_PROPELLANT_LF_AMOUNT) + " L" at (0,20).
    print "OX: " + floor(_S1_PROPELLANT_OX_AMOUNT) + " L" at (0,21).
    print "Overall: " + _PROPELLANT_PERCENTAGE("Stage 1") at (0,22).
    print "Recent Event: " at (0, 23).
}



// EVENT LIST

GLOBAL FUNCTION _FLIGHT_MAIN { // Contains events and the countdown time for them
        if _VEHICLE_CONFIGURATION = "Capsule" {global _CREW_ARM_ENABLED is true.} else if _VEHICLE_CONFIGURATION = "Payload" {global _CREW_ARM_ENABLED is false.}
        IF _T = _COUNTDOWN_CREW_ARM and _CREW_ARM_ENABLED = true { // Retract crew arm
            if _DEBUG_MENU_ACTIVE = true {print "Crew Arm" at (14,23).}
            log "Crew Arm Retraction at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
        } ELSE IF _T <= _COUNTDOWN_FUEL_START and _FUEL_VALVE = false { // Start fueling process
            log "Fuel Load Start at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
            if _DEBUG_MENU_ACTIVE = true {print "Fueling Begin" at (14,23).}
            for p in _GND_TWR_VENT {
                local m is p:getmodulebyindex(0).
                for a in m:allactionnames() {
                    if a:contains("Activate Engine") {m:doaction(a, true).}
                }
            }
            set _FUEL_VALVE to true.
        } ELSE IF _T <= _COUNTDOWN_FUEL_STOP and _FUEL_VALVE = true { // Stop fueling process
            log "Fuel Load Stop at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
            if _DEBUG_MENU_ACTIVE = true {print "Fueling Stop" at (14,23).}
            for p in _GND_TWR_VENT {
                if p:modules:contains("ModuleEnginesFX") {
                    local m is p:getmodule("ModuleEnginesFX").
                    for a in m:allactionnames() {
                        if a:contains("Shutdown Engine") {m:doaction(a, true).}
                    }
                }
            }
            set _FUEL_VALVE to "Finished".
        } ELSE IF _T = _COUNTDOWN_CORE_IGNITION { // Ignite Main Engines
            if _DEBUG_MENU_ACTIVE = true {print "Main Engine Ignition" at (14,23).}
            log "Main Engine Ignition at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.

            for p in _GND_DELUGE {
                local m is p:getmodule("ModuleEnginesFX").
                m:doevent("Activate Engine").
            }

            _ENGINE_CONTROL("Stage 1", "startup").
            LOCK THROTTLE TO 1.

            _MESSAGE_SENDER("STAGE 2", "LIFTOFF"). // Send stage 2 the message that we are ready to lift off
        } ELSE IF _T = 0 { // RELEASE
        log "Liftoff at: " + round(kuniverse:realworldtime) to _EVT_DATA_DIRECTORY.
            _GND_UMBILICAL_UPPER:getmodulebyindex(10):doaction("toggle arm right", true). // Move the unbilicals
            _GND_UMBILICAL_LOWER:getmodulebyindex(10):doaction("toggle arm right", true). 

            for p in _GND_CLAMP { // Ground Clamp
                local m is p:getmodulebyindex(1).
                for a in m:allactionnames() {
                    if a:contains("toggle arm") {m:doaction(a, true).}
                }
            }

            _ENGINE_CONTROL("SRB", "ignite").

            _GND_PAD:getmodule("LaunchClamp"):doaction("release clamp", true).      
        }
}

global function _SF_MAIN {
    if _T = _SF_COUNTDOWN_FUEL_BEGIN {
        log "Fuel Load Start at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
        if _DEBUG_MENU_ACTIVE = true {print "Fueling Begin" at (14,23).}
        for p in _GND_TWR_VENT {
            local m is p:getmodulebyindex(0).
            for a in m:allactionnames() {
                if a:contains("Activate Engine") {m:doaction(a, true).}
            }
        }
    } else if _T = _SF_COUNTDOWN_FUEL_STOP {
        log "Fuel Load Stop at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
        if _DEBUG_MENU_ACTIVE = true {print "Fueling Stop" at (14,23).}
        for p in _GND_TWR_VENT {
            if p:modules:contains("ModuleEnginesFX") {
                local m is p:getmodule("ModuleEnginesFX").
                for a in m:allactionnames() {
                    if a:contains("Shutdown Engine") {m:doaction(a, true).}
                }
            }
        }
    } else if _T = _SF_COUNTDOWN_CORE_IGNITION {
        if _DEBUG_MENU_ACTIVE = true {print "Main Engine Ignition" at (14,23).}
        log "Main Engine Ignition at: " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.

        for p in _GND_DELUGE {
            local m is p:getmodule("ModuleEnginesFX").
            m:doevent("Activate Engine").
        }

        _ENGINE_CONTROL("Stage 1", "startup").
        LOCK THROTTLE TO 1.
        _MESSAGE_SENDER("STAGE 2", "STATIC FIRE").
    } 
}

// COMMMUNICATIONS

GLOBAL FUNCTION _MESSAGE_LISTENER { // LISTEN FOR MESSAGES AND DECODE
    IF not SHIP:MESSAGES:EMPTY { // WAIT FOR MESSAGE TO BE IN LIST
        set _MSGRECIEVED to ship:messages:pop. // Assigns variable to message recieved
        GLOBAL _DECODED_MSG TO _MSGRECIEVED:content. // Stores message in a decoded format
        PRINT _DECODED_MSG. // Print to show it works
    }
}

GLOBAL FUNCTION _MESSAGE_SENDER { // SENDS MESSAGE TO OTHER VESSELS
    PARAMETER _TARGET, _CONTENTS.
    // _DEFINE_COMPUTERS(). // Get computers for vehicle

    IF _TARGET = "STAGE 1" {
        LOCAL _S1_CORE_CONNECTION IS _S1_CORE:getmodule("kOSProcessor"):connection.
        _S1_CORE_CONNECTION:SENDMESSAGE(_CONTENTS).
    } ELSE IF _TARGET = "STAGE 2" {
        LOCAL _S2_CORE_CONNECTION IS _S2_CORE:getmodule("kOSProcessor"):connection.
        _S2_CORE_CONNECTION:SENDMESSAGE(_CONTENTS).
    } ELSE IF _TARGET = "GROUND" {
        LOCAL _GND_CORE_CONNECTION IS _GND_CORE:getmodule("kOSProcessor"):connection.
        _GND_CORE_CONNECTION:SENDMESSAGE(_CONTENTS).
    } ELSE IF _TARGET = "CAPSULE" {
        local _CAP_CORE_CONNECTION is _CAP_CORE:getmodule("kOSProcessor"):connection.
        _CAP_CORE_CONNECTION:SENDMESSAGE(_CONTENTS).
    } ELSE IF _TARGET = "BOOSTER" {
        FOR P in _BOOST_CORE {
            IF P:MODULES:CONTAINS("kOSProcessor") { // If the parts contain the module
                local _BOOST_CORE_CONNECTION is p:getmodule("kOSProcessor"):connection.
                _BOOST_CORE_CONNECTION:SENDMESSAGE(_CONTENTS).
            }
        }
    }
}







// AZIMUTH CALCULATION & VECTOR FUNCTIONS & extra launch calculation shit

GLOBAL FUNCTION _LAUNCH_AZIMUTH { // From KSLib
    PARAMETER _TARGET_INCLINE, _ORBIT_ALT, _RAW is false, _AUTOSWITCH is false.

    LOCAL _SHIP_LAT is ship:latitude.
    LOCAL _RAW_HEAD IS 0. // Azimuth without auto switch

    IF ABS(_TARGET_INCLINE) < abs(_SHIP_LAT) {set _TARGET_INCLINE TO _SHIP_LAT.}
    IF (_TARGET_INCLINE > 180) {set _TARGET_INCLINE to -360 + _TARGET_INCLINE.}
    IF (_TARGET_INCLINE < -180) {set _TARGET_INCLINE to 360 + _TARGET_INCLINE.}
    IF hasTarget {SET _AUTOSWITCH to true.}

    LOCAL _HEAD IS arcSin(max(min(cos(_TARGET_INCLINE) / cos(_SHIP_LAT), 1), -1)).
    set _RAW_HEAD to _HEAD.

    IF _AUTOSWITCH {
        IF _NODE_SIGN_TARGET() > 0 {set _HEAD to 180 - _HEAD.}
    } ELSE IF (_TARGET_INCLINE < 0) {set _HEAD to 180 - _HEAD.}

    LOCAL _EQ_VEL is (2 * constant:pi * body:radius) / body:rotationperiod.
    local _V_ORBIT is sqrt(body:mu / (_ORBIT_ALT + body:radius)).
    LOCAL _V_ROT_X is _V_ORBIT * sin(_HEAD) - (_EQ_VEL * cos(_SHIP_LAT)).
    LOCAL _V_ROT_Y is _V_ORBIT * cos(_HEAD).
    
    SET _HEAD TO 90 - arcTan2(_V_ROT_Y, _V_ROT_X).

    IF _RAW {return mod(_RAW_HEAD + 360, 360).}
    ELSE {return mod(_HEAD + 360, 360).}
}

LOCAL FUNCTION _NODE_SIGN_TARGET { // approaching AN or DN
	if (hasTarget) {
		local joinVec is vcrs(_ORBIT_BINORMAL(), _TARGET_BINORMAL()):normalized.
		local signVec is vcrs(-body:position:normalized, joinVec):normalized.
		local sign is vdot(_ORBIT_BINORMAL(), signVec).

		if (sign > 0) { return 1. }
		else { return -1. }
	} 
	else { return 1. }
}

LOCAL FUNCTION _ORBIT_TANGENT { // ship velocity
    parameter ves is ship.

    return ves:velocity:orbit:normalized.
}

LOCAL FUNCTION _ORBIT_BINORMAL { // ship binormal
    parameter ves is ship.

    return vcrs((ves:position - ves:body:position):normalized, _ORBIT_TANGENT(ves)):normalized.
}

LOCAL FUNCTION _TARGET_BINORMAL { // target binormal
    parameter ves is target.

    return vcrs((ves:position - ves:body:position):normalized, _ORBIT_TANGENT(ves)):normalized.
}

GLOBAL FUNCTION _INCLINE_MANAGER { // Copied from raizspace code on the shuttle to correct inclination
    parameter maxDeviation.
	
	set incDiff to SHIP:ORBIT:INCLINATION - _INCLINE_TARGET.

	if incDiff > 0.05 {
		if _PROGRADE_HEAD < 90 AND _INCLINE_CORRECTION < maxDeviation{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION + (maxDeviation/100).
		}
		if _PROGRADE_HEAD > 90 AND _INCLINE_CORRECTION > -maxDeviation{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION - (maxDeviation/100).
		}
	}
	if incDiff < -0.05{
		if _PROGRADE_HEAD < 90 AND _INCLINE_CORRECTION > -maxDeviation{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION - (maxDeviation/100).
		}
		if _PROGRADE_HEAD > 90 AND _INCLINE_CORRECTION < maxDeviation{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION + (maxDeviation/100).
		}
	}
	
	if incDiff < 0.05 AND incDiff > -0.05{
		if _INCLINE_CORRECTION > 0{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION - (maxDeviation/100).
		}
		
		if _INCLINE_CORRECTION < 0{
			set _INCLINE_CORRECTION to _INCLINE_CORRECTION + (maxDeviation/100).
		}
	}	
}

GLOBAL FUNCTION _HEADING_OF_VECTOR { // Allows us to use a vector as a heading for steering
    PARAMETER VECT.

    LOCAL EAST IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).

    LOCAL TRIG_X IS VDOT(SHIP:NORTH:VECTOR, VECT).
    LOCAL TRIG_Y IS VDOT(EAST, VECT).

    LOCAL RESULT IS ARCTAN2(TRIG_Y, TRIG_X).

    IF RESULT < 0 {RETURN 360 + RESULT.} ELSE {RETURN RESULT.}
}

GLOBAL FUNCTION _COMPASS_FOR {
	
	set pointing to ship:prograde:forevector.
	set east to _EAST_FOR().

	set trig_x to vdot(ship:north:vector, pointing).
	set trig_y to vdot(east, pointing).

	set result to arctan2(trig_y, trig_x).

	if result < 0 { 
		return 360 + result.
	} else {
		return result.
	}
}

GLOBAL FUNCTION _EAST_FOR {
    return vcrs(ship:up:vector, ship:north:vector).
}

GLOBAL FUNCTION _WINDOW { // Timed launch window for Narvi / Target docking missions
    PARAMETER _TARGET.

    LOCAL _LAT is ship:latitude.
    LOCAL _ECLIPTIC_NORM is vCrs(_TARGET:OBT:VELOCITY:ORBIT, _TARGET:BODY:POSITION - _TARGET:POSITION):NORMALIZED.
    LOCAL _PLANET_NORM is heading(_TARGET_SPACECRAFT:obt:inclination - ship:obt:inclination, _LAT):VECTOR.
    LOCAL _BODYINCLINE is vAng(_PLANET_NORM, _ECLIPTIC_NORM). // Finds the inclination on the variables above
    LOCAL _BETA is arcCos(max(-1, min(1, cos(_BODYINCLINE) * SIN(_LAT) / sin(_BODYINCLINE)))).
    LOCAL _INTERSECT_DIR is vCrs(_PLANET_NORM, _ECLIPTIC_NORM):normalized.
    LOCAL _INTERSECT_POS is -vxcl(_PLANET_NORM, _ECLIPTIC_NORM):normalized.

    LOCAL _LAUNCHTIME_DIR is (_INTERSECT_DIR * sin(_BETA) + _INTERSECT_POS * cos(_BETA)) * cos(_LAT) + sin(_LAT) * _PLANET_NORM.
    LOCAL _LAUNCHTIME is vAng(_LAUNCHTIME_DIR, ship:position - body:position) / 360 * body:rotationperiod. 

    IF vCrs(_LAUNCHTIME_DIR, ship:position - body:position) * _PLANET_NORM < 0 {
        set _LAUNCHTIME to body:rotationperiod - _LAUNCHTIME.
    }

    RETURN time:Seconds + _LAUNCHTIME. // Value for countdown 
}

// FORMATTING FUNCTIONS

GLOBAL FUNCTION _CONVERT_LEXITIME {
    PARAMETER _LEXICON.

    SET _HOUR TO _LEXICON:HOUR * 3600.
    SET _MINS TO _LEXICON:MINS * 60.
    SET _SECS TO _LEXICON:SECS * 1.

    SET _SECOND_CONVERSION TO _HOUR + _MINS + _SECS.
    RETURN _SECOND_CONVERSION.
}

GLOBAL FUNCTION _CLOCK_TIME {
    parameter time_Unit.

    local hour_Zero is "".
    local minute_Zero is "".
    local second_Zero is "".

    local hour_Floor is floor(time_Unit / 3600).
    local minute_Floor is floor((time_Unit - (hour_Floor * 3600)) / 60).
    local second_Floor is floor(time_Unit - (hour_Floor * 3600) - (minute_Floor * 60)).

    if hour_Floor < 10 {set hour_Zero to "0".} else {set hour_Zero to "".}
    if minute_Floor < 10 {set minute_Zero to "0".} else {set minute_Zero to "".}
    if second_Floor < 10 {set second_Zero to "0".} else {set second_Zero to "".}
    
    local time_Unit_Formatted is hour_Zero + hour_Floor + ":" + minute_Zero + minute_Floor + ":" + second_Zero + second_Floor.
    return time_Unit_Formatted.
}



// PROPELLANT

GLOBAL FUNCTION _VEHICLE_PROPELLANT {
    PARAMETER _STAGE.

    IF _STAGE = "STAGE 1" {
        FOR res in _S1_FUEL_TANK:resources {
            IF RES:NAME = "LiquidFuel" {
                set _S1_PROPELLANT_LF_AMOUNT TO RES:AMOUNT * 2.
                set _S1_PROPELLANT_LF_CAPACITY TO RES:CAPACITY * 2.
                }
            IF RES:NAME = "Oxidizer" {
                set _S1_PROPELLANT_OX_AMOUNT TO RES:AMOUNT * 2.
                set _S1_PROPELLANT_OX_CAPACITY TO RES:CAPACITY * 2.
            }
        }
    } ELSE IF _STAGE = "STAGE 2" {
        for res in _S2_FUEL_TANK:resources {
                if res:name = "LqdHydrogen" {
                    set _S2_PROPELLANT_CH2_AMOUNT TO RES:AMOUNT.
                    set _S2_PROPELLANT_CH2_CAPACITY TO RES:CAPACITY.
                }
                if res:name = "Oxidizer" {
                    set _S2_PROPELLANT_OX_AMOUNT TO RES:AMOUNT.
                    set _S2_PROPELLANT_OX_CAPACITY TO RES:CAPACITY.
                }
            }
    }
}

GLOBAL FUNCTION _PROPELLANT_PERCENTAGE {
    PARAMETER _STAGE.

    IF _STAGE = "STAGE 1" {
        _VEHICLE_PROPELLANT("STAGE 1"). // Grab fuel for the calculation
        local _PROPELLANT_PERCENTAGE_VAL TO ROUND(((_S1_PROPELLANT_LF_AMOUNT + _S1_PROPELLANT_OX_AMOUNT) / (_S1_PROPELLANT_LF_CAPACITY + _S1_PROPELLANT_OX_CAPACITY)) * 100, 2) + "%". 
        RETURN _PROPELLANT_PERCENTAGE_VAL.
    } ELSE IF _STAGE = "STAGE 2" {
        _VEHICLE_PROPELLANT("STAGE 2"). // Grab fuel for the calculation
        local _PROPELLANT_PERCENTAGE_VAL to round(((_S2_PROPELLANT_CH2_AMOUNT + _S2_PROPELLANT_OX_AMOUNT) / (_S2_PROPELLANT_CH2_CAPACITY + _S2_PROPELLANT_OX_CAPACITY)) *100, 2) + "%".
        return _PROPELLANT_PERCENTAGE_VAL.    
    } ELSE IF _STAGE = "BOOSTER" {

    }
}

// to be put into an organised order

GLOBAL FUNCTION _ENGINE_CONTROL { // Engine Control
    PARAMETER _stage, _action.

    if _stage = "Stage 1" {
        if _action = "startup" {
            for p in _S1_ENG {
            local m is p:getmodule("ModuleEnginesFX").
                m:doaction("Activate Engine", true).
            }
        } else if _action = "shutdown" {
            for p in _S1_ENG {
            local m is p:getmodule("ModuleEnginesFX").
                m:doaction("Shutdown Engine", true).
            }
        }
    } else if _stage = "Stage 2" {
        if _action = "startup" {
            for p in _S2_ENG {
                    local M is P:getmodule("ModuleEnginesFX").
                    m:doaction("Activate Engine", true).
                }
            } else if _action = "shutdown" {
            for p in _S2_ENG {
                local M is P:getmodule("ModuleEnginesFX").
                    m:doaction("Shutdown Engine", true).  
                }      
            }
    } else if _stage = "SRB" {
        if _action = "ignite" {
            for p in _SRB_ENG {
                local m is p:getmodule("ModuleEnginesFX").
                for a in m:allactionnames() {
                    if a:contains("activate engine") {m:doaction(a, true).}
                }
            }
        }
    } 
}

global function _FLIGHTTERMINATION {
    parameter _FTS_STAGE.

    IF _FTS_STAGE = "STAGE 1" {
        _S1_FTS:getmodule("TacselfDestruct"):doaction("Detonate Parent!", true). // Stage 1 tank destroys
        _SEPARATE_SRBS().
    } ELSE IF _FTS_STAGE = "STAGE 2" {
        _S2_FTS:getmodule("TacselfDestruct"):doaction("Detonate Parent!", true).
    }
}


// Event Logging

global function _EVT_LOGGING_PRECHECK {
    parameter _STAGE.


    local _EVT_BASE_DIRECTORY is "0:/Data/Telesto/Event_Logs". // Base Directory

    if NOT(EXISTS(_EVT_BASE_DIRECTORY)) {createDir(_EVT_BASE_DIRECTORY).}
    cd(_EVT_BASE_DIRECTORY).

    list files in _EVT_BASE_DIRECTORY_FILE_LIST.

    global _EVT_THIS_FLIGHT_NUMBER is _EVT_BASE_DIRECTORY_FILE_LIST:length + 1.
    local _EVT_FLIGHT_LOG_DIRECTORY is _EVT_BASE_DIRECTORY + "/Flight" + _EVT_THIS_FLIGHT_NUMBER.



    if _STAGE = "Pre-Launch" {
    IF NOT(EXISTS(_EVT_FLIGHT_LOG_DIRECTORY)) {CREATEDIR(_EVT_FLIGHT_LOG_DIRECTORY).} // Creates the fookin folder
    global _EVT_DATA_DIRECTORY to _EVT_FLIGHT_LOG_DIRECTORY + "/FLIGHT_" + _EVT_THIS_FLIGHT_NUMBER + "_EVT_LOG.txt".
    LOG "FLIGHT: " + _EVT_THIS_FLIGHT_NUMBER + " EVENT LOGGING SHEET" to _EVT_DATA_DIRECTORY.

    } else if _STAGE = "Launch" {
            local _EVT_THIS_FLIGHT_NUMBER is _EVT_THIS_FLIGHT_NUMBER - 1.
            local _EVT_FLIGHT_LOG_DIRECTORY is _EVT_BASE_DIRECTORY + "/Flight" + _EVT_THIS_FLIGHT_NUMBER.
            global _EVT_DATA_DIRECTORY is _EVT_FLIGHT_LOG_DIRECTORY + "/FLIGHT_" + _EVT_THIS_FLIGHT_NUMBER + "_EVT_LOG.txt".
    } else if _STAGE = "Capsule" {
        local _EVT_THIS_FLIGHT_NUMBER is _EVT_THIS_FLIGHT_NUMBER - 1.
        local _EVT_FLIGHT_LOG_DIRECTORY is _EVT_BASE_DIRECTORY + "/Flight" + _EVT_THIS_FLIGHT_NUMBER.
        global _EVT_DATA_DIRECTORY is _EVT_FLIGHT_LOG_DIRECTORY + "/FLIGHT_" + _EVT_THIS_FLIGHT_NUMBER + "_EVT_LOG.txt".
    }
}