#include "crexxpa.h"

PROCEDURE(sdkversion)
{
    const char *version = rxpa_version;
    SETSTRING(RETURN, version);
    RESETSIGNAL
}

PROCEDURE(addints)
{
    RETURNINT(GETINT(ARG0) + GETINT(ARG1));
    RESETSIGNAL
}

LOADFUNCS
ADDPROC(sdkversion, "sdk_probe.sdkversion", "b", ".string", "");
ADDPROC(addints, "sdk_probe.addints", "b", ".int", "left=.int,right=.int");
ENDLOADFUNCS
