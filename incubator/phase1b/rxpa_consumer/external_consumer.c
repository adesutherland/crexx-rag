#include "crexxpa.h"

PROCEDURE(installedversion)
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
ADDPROC(installedversion, "external_consumer.installedversion", "b", ".string", "");
ADDPROC(addints, "external_consumer.addints", "b", ".int", "left=.int,right=.int");
ENDLOADFUNCS
