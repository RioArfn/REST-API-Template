namespace RAT.Integration;

page 90000 "Integration Setup RAT"
{
    ApplicationArea = All;
    Caption = 'Integration Setup RAT';
    PageType = Card;
    SourceTable = "Integration Setup RAT";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Show Payload"; Rec."Show Payload")
                {
                    ToolTip = 'Specifies the value of the Show Payload field.', Comment = '%';
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the value of the User Name field.', Comment = '%';
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Specifies the value of the Password field.', Comment = '%';
                }
                field("Main URL"; Rec."Main URL")
                {
                    ToolTip = 'Specifies the value of the Main URL field.', Comment = '%';
                }
                field("Endpoint 1"; Rec."Endpoint 1")
                {
                    ToolTip = 'Specifies the value of the Endpoint 1 field.', Comment = '%';
                }
                field("Endpoint 2"; Rec."Endpoint 2")
                {
                    ToolTip = 'Specifies the value of the Endpoint 2 field.', Comment = '%';
                }
            }
        }
    }
}
