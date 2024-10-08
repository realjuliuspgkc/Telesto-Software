// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//      Booster Main
// ------------------------

_BOOSTER_COMPUTER_INIT().

GLOBAL FUNCTION _BOOSTER_COMPUTER_INIT {
    wait 1.
    ag1 on.
    wait 5.
    ag3 on.
    wait 0.5.
    ag10 on.
    wait 5.
    ag2 on.

    until ag7 {
        lock steering to prograde.
    }
    sas on.
    wait 1.
    unlock steering.
    wait 1.
    shutdown.
}


