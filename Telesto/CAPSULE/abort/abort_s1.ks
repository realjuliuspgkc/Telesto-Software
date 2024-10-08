runoncepath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // get the settings
runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // get the part list

_DEFINE_TELESTO_S2().
_DEFINE_TELESTO_CAPSULE().

// ABORT ABORT ABORT



LOCK THROTTLE TO 1. // MAX THROTTLE


SET _CURRENT_ABORT_FACING TO SHIP:FACING.
LOCK STEERING TO _CURRENT_ABORT_FACING. // STEER STRAIGHT AND GET AWAY 
_CAP_SEP:getmodule("ModuleDecouple"):doaction("Decouple", true).
_CAP_ABORT:getmodulebyindex(4):doaction("abort!", true).

WAIT 10. // TIME TO GET AWAY FROM TELESTO (it will be exploding)
LOCK THROTTLE TO 0.
LOCK STEERING TO SRFPROGRADE.

WAIT UNTIL SHIP:VERTICALSPEED < 5. // Wait to start steering retrograde
LOCK STEERING TO SRFRETROGRADE. // STEER RETRO AS TO NOT SCARE THE CREW

STAGE.
WAIT 0.1.
STAGE.
WAIT 0.1.
STAGE. // GET RID OF EVERYHTING & PARACHUTE DEPLOY

UNTIL SHIP:VERTICALSPEED < 1 {wait 0.}
SHUTDOWN. // WE ARE NOW SPLASHED DOWN