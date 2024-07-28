// Saturn Aerospace 2024
// 
// Made By Julius & Quasy
//    Telesto V4
// 
// ------------------------
//   Mission Settings
// ------------------------
// WORKS ON THE "Telesto V4" VEHICLE

GLOBAL _MISSION_SETTINGS IS LEXICON(
    "MISSION NAME", "OFT-2",

    "APOGEE", 150, // HIGHEST POINT IN ORBIT (IN KM)
    "PERIGEE", 150, // LOWEST POINT IN ORBIT (IN KM)
    "INCLINATION", 23, // INCLINATION

    "ROCKET CONFIG", "Capsule", // EITHER PAYLOAD OR CAPSULE.
    "COUNTDOWN TYPE", "Launch", // EITHER "Static Fire" OR "Launch"
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
    "G-Force Limit", 5
).