clearscreen.
_RETURN_INIT().

local function _RETURN_INIT {
    runoncepath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Ground Functions
    runOncePath("0:/SaturnAerospace/Telesto/BOOSTER/functions.ks"). // SRB functions
    runOncePath("0:/SaturnAerospace/Telesto/mission_settings.ks"). // Mission Setings
    runoncepath("0:/SaturnAerospace/Telesto/part_list.ks"). // Part List

    set _LHINGE_LOCK to false.
    set _RHINGE_LOCK to false.
    _DEFINE_SETTINGS().
    _DEFINE_TELESTO_SRB().
    set _RWY_TGT to latlng(1111, 1111). // need to figure out what the latlong is
    set _RWY_ALIGNMENT to latlng(111, 111). // need to get osha to grab a position
    set _PITCHOFFSET to 90.
    set _LATOFFSET to 0.
    set _LNGOFFSET to 0.

    _RETURN().
}

local function _RETURN {
    // Functions to be added/how things will work
    _WING_DEPLOY(). // wing deploy & lock
    // _GLIDE_BACK().// glide back to skid pad/runway (try use PH guidance code? but yet again probs gonna need to do something different as PH return code is for vertical not horizontal.)
    // gears
    // landing
}


local function _WING_DEPLOY {
    wait 5. // waits for 5 seconds to ensure its away from the rocket.
    _RIGHT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("locked", false).
    _LEFT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("locked", false).
    print "Unlocked".
    wait 1.
    _RIGHT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("target angle", 0.1).
    _LEFT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("target angle", 0.1).
    print "Target angle set to 0. Moving now.".


    until _LHINGE_LOCK = true and _RHINGE_LOCK = true {
        until _RHINGE_LOCK = true {
            until _RIGHT_HINGE:getmodule("ModuleRoboticServoHinge"):getfield("locked") = true {
                _RIGHT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("locked", true).
                wait 0.5.
            }
            set _RHINGE_LOCK to true.
        }
        wait 0.5.
        until _LHINGE_LOCK = true {
            until _LEFT_HINGE:getmodule("ModuleRoboticServoHinge"):getfield("locked") = true {
                _LEFT_HINGE:getmodule("ModuleRoboticServoHinge"):setfield("locked", true).
                wait 0.5.
            }
            set _LHINGE_LOCK to true.
        }
        wait 0.5.
    }
    print "Both are now locked.".
}

local function _GLIDE_BACK {
    lock steering to prograde.

    until ship:verticalSpeed <= 1 {
        print "Waiting for vertical speed to get <= 1 which means we are falling back to earth".
        wait 0.1.
    }
    _GLIDE_CONTROL().
}