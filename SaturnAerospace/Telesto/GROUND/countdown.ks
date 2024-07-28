// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//      Telesto V1
// 
// ------------------------
//   Countdown Ground
// ------------------------

clearScreen.
_GROUND_CPU_INIT(). // Run the GROUND portion

GLOBAL FUNCTION _GROUND_CPU_INIT {
    // Required Files
        runOncePath("0:/SaturnAerospace/Telesto/GROUND/functions.ks"). // Functions for the countdown & mission setup
        runOncePath("0:/SaturnAerospace/Telesto/mission_Settings.ks"). // Settings for the mission
        runOncePath("0:/SaturnAerospace/Telesto/part_list.ks"). // Parts on the vehicle

    // Initialisation
        AG6 OFF.
        AG9 OFF.
        AG10 OFF.
        RCS OFF.
        SAS OFF.

        _DEFINE_SETTINGS(). // Grab settings for the mission
        _DEFINE_COUNTDOWN(). // Grab countdown items
        _DEFINE_COMPUTERS(). // CPU Cores
        _DEFINE_PAD_PARTS(). // Pad parts
        _DEFINE_TELESTO_S1(). // Stage 1 parts
        _DEFINE_TELESTO_S2(). // Stage 2 parts
        _DEFINE_TELESTO_SRB(). // SRB Parts
        _DEFINE_TELESTO_CAPSULE(). // Capsule parts
        _EVT_LOGGING_PRECHECK("Pre-Launch").
        log "PRE-LAUNCH" to _EVT_DATA_DIRECTORY.
        
        _VEHICLE_PROPELLANT("Stage 1").
        // _VEHICLE_PROPELLANT("SRB").

    // Sequence
        _GROUND_COUNTDOWN(_COUNTDOWN_START, _COUNTDOWN_TYPE).
}



// ------------------------------------------

GLOBAL FUNCTION _GROUND_COUNTDOWN {
    PARAMETER _T_TIME, _T_TYPE.
    GLOBAL _T IS _T_TIME.

    if _T_TYPE = "Static Fire" {
        log "Static Fire Selected" to _EVT_DATA_DIRECTORY.
        UNTIL missionTime = 1 { // For non rendezvous missions
            _MANUAL_HOLD_CHECK(). // AG9 TO ABORT.
            _AUTOMATIC_VALIDATION(). // AUTOMATIC VEHICLE VALIDATION
            _SF_MAIN(). // COUNTDOWN EVENTS
            _MESSAGE_LISTENER(). // LISTEN FOR OTHER MESSAGES FROM SEPARATE COMPUTERS

            // VISUAL
                PRINT "T-" + _CLOCK_TIME(_T) + "            " at (1,1).
                LOG "T-" + _CLOCK_TIME(_T) TO "0:/Data/Telesto/mission_Time.txt".

            if _DEBUG_MENU_ACTIVE = true { _PRINT_DEBUG(). }

            // LOGIC 
                IF _T > kuniverse:realworldtime {
                    SET _T to _T - kuniverse:realworldtime.
                } ELSE IF _T = 0 or _T < kuniverse:realworldtime {
                    set _T to _T - 0.5.
                }

            // BREAK
                IF _T < 0 {
                    wait 0.5. 
                    break.
                }

            wait 0.5. // Half Second Loops
        }
    } ELSE IF _T_TYPE = "Launch" {
        log "Launch Mode Selected" to _EVT_DATA_DIRECTORY.
        log _VEHICLE_CONFIGURATION + " is the set vehicle config." to _EVT_DATA_DIRECTORY.
        log "Launch Countdown beginning from T- " + _CLOCK_TIME(_T) to _EVT_DATA_DIRECTORY.
        UNTIL missionTime = 1 { // For non rendezvous missions
            _MANUAL_HOLD_CHECK(). // AG9 TO ABORT.
            _AUTOMATIC_VALIDATION(). // AUTOMATIC VEHICLE VALIDATION
            _FLIGHT_MAIN(). // COUNTDOWN EVENTS
            _MESSAGE_LISTENER(). // LISTEN FOR OTHER MESSAGES FROM SEPARATE COMPUTERS

            // VISUAL
                PRINT "T-" + _CLOCK_TIME(_T) + "            " at (1,1).
                LOG "T-" + _CLOCK_TIME(_T) TO "0:/Data/Telesto/mission_Time.txt".

            if _DEBUG_MENU_ACTIVE = true { _PRINT_DEBUG(). }

            // LOGIC 
                IF _T > kuniverse:realworldtime {
                    SET _T to _T - kuniverse:realworldtime.
                } ELSE IF _T = 0 or _T < kuniverse:realworldtime {
                    set _T to _T - 0.5.
                }

            // BREAK
                IF _T < 0 {
                    wait 2. 
                    break.
                }

            wait 0.5. // Half Second Loops
        }
    }


    

    SHUTDOWN. // Close CPU as it is no longer needed (if abort this would be full recycle)
}