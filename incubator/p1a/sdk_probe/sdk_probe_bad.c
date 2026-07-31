#include "crexxpa.h"

PROCEDURE(addintsbad)
{
    RETURNINT(GETINT(ARG0) + GETINT(ARG1));
    RESETSIGNAL
}

LOADFUNCS
ADDPROC(addintsbad, "sdk_probe_bad.addints", "b", ".int", ".int,.int");
ENDLOADFUNCS
