namespace RAT;

using RAT.Integration;

permissionset 90000 RAT
{
    Assignable = true;
    Permissions = tabledata "Integration Setup RAT" = RIMD,
        table "Integration Setup RAT" = X,
        tabledata "Integration Log RAT" = RIMD,
        table "Integration Log RAT" = X,
        codeunit "Integration Management RAT" = X,
        page "Integration Setup RAT" = X;
}