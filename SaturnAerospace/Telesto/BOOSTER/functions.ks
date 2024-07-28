global function _GLIDE_CONTROL {
    // pitch, yaw, roll
    
    
}


local function _STEERTORUNWAY {
    parameter _PITCH is 1, _OVSHTLATMOD is 0, _OVSHTLNGMOD is 0.

    
}


local function _GEODIR {
    parameter geo1, geo2.

    return arcTan2(geo1:lng - geo2:lng, geo1:lat - geo2:lat).
}