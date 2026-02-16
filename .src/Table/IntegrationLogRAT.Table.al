namespace RAT.Integration;
table 90001 "Integration Log RAT"
{
    Caption = 'Integration Log RAT';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "API DateTime"; DateTime)
        {
            Caption = 'API Date/Time';
            DataClassification = SystemMetadata;
        }
        field(5; "Source Record"; RecordId)
        {
            Caption = 'Source Record';
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "API Status RAT")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(7; "Error Message"; Text[2000])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
