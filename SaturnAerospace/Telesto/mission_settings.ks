// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//    Telesto V5
// 
// ------------------------
//   Mission Settings
// ------------------------
// WORKS ON THE "Telesto V5" VEHICLE

GLOBAL _MISSION_SETTINGS IS LEXICON(
    "MISSION NAME", "OFT-4",

    "APOGEE", 150, // HIGHEST POINT IN ORBIT (IN KM) for capsule, this is the final orbit it will move itself up to from parking orbit. (IF DOCKING WITH SOMETHING, MAKE THIS THE ORBIT OF THE TARGET)
    "PERIGEE", 150, // LOWEST POINT IN ORBIT (IN KM) for capsule, this is the final orbit it will move itself up to from parking orbit. (IF DOCKING WITH SOMETHING, MAKE THIS THE ORBIT OF THE TARGET)
    "INCLINATION", 23, // INCLINATION (MAKE THIS INCLINATION THE TARGET INCLINATION IF DOCKING)

    "ROCKET CONFIG", "Capsule", // EITHER PAYLOAD OR CAPSULE.
    "COUNTDOWN TYPE", "Launch", // EITHER "Static Fire" OR "Launch"
    "TARGET VESSEL","None", // Whether to rendezvous with a craft/station. SET TO "FALSE" IF DOING A NON-RENDEZVOUS.
    "DEBUG SHOW", true // Shows the built in Debug Menu
).

GLOBAL _COUNTDOWN_EVENTS IS LEXICON(
    // Normal Launch Variables.
    "COUNTDOWN BEGIN", LEXICON("HOUR", 0, "MINS", 0, "SECS", 10), // COUNTDOWN BEGIN (DOES NOT LAUNCH AT A CERTAIN TIME, PRIMARILY USED FOR TESTING)
    "COUNTDOWN BEGIN (UNIX)", LEXICON("UNIX", 0), // COUNTDOWN BEGIN UNIX, (IF NOT USING SET TO 0)

    "CREW ARM RETRACT", LEXICON("HOUR", 0, "MINS", 25, "SECS", 50), // Crew Arm Retraction Time (Not used till telesto is capable of crew)
    "FUEL LOADING BEGIN", LEXICON("HOUR", 0, "MINS", 25, "SECS", 45), // FUELING START TIME
    "FUEL LOADING CLOSEOUT", LEXICON("HOUR", 0, "MINS", 3, "SECS", 30), // FUELING CLOSEOUT TIME

    "CORE IGNITION", LEXICON("HOUR", 0, "MINS", 0, "SECS", 3), // CORE ENGINE IGNITION 


    // Static Fire Variables
    "SF COUNTDOWN BEGIN", lexicon("HOUR", 0, "MINS", 0, "SECS", 5),
    "SF COUNTDOWN BEGIN (UNIX)", LEXICON("UNIX", 0), // COUNTDOWN BEGIN UNIX, (IF NOT USING SET TO 0)

    "Fuel Load Begin", lexicon("HOUR", 0, "MINS", 25, "SECS", 45),
    "Fuel Load Close-out", LEXICON("HOUR", 0, "MINS", 3, "SECS", 30), // FUELING CLOSEOUT TIME

    "IGNITION", lexicon("HOUR", 0, "MINS", 0, "SECS", 0),
    "SF Duration", 15 // Seconds
).

global _EXTRA is lexicon(
    "G-Force Limit", 5,
    "Parking Orbit", 150
).