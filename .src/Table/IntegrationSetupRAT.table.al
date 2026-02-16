namespace RAT.Integration;
table 90000 "Integration Setup RAT"
{
    Caption = 'Integration Setup RA';
    DataClassification = CustomerContent;
    AllowInCustomizations = AsReadWrite;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "User Name"; Text[250])
        {
            Caption = 'User Name';
        }
        field(3; "Password"; Text[250])
        {
            Caption = 'Password';
        }
        field(4; "Main URL"; Text[250])
        {
            Caption = 'Main URL';
        }
        field(5; "Endpoint 1"; Text[250])
        {
            Caption = 'Endpoint 1';
        }
        field(6; "Endpoint 2"; Text[250])
        {
            Caption = 'Endpoint 2';
        }
        field(13; "Show Payload"; Boolean)
        {
            Caption = 'Show Payload';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
