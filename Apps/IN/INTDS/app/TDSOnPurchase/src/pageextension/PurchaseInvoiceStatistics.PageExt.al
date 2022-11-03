pageextension 18717 "Purchase Invoice Statistics" extends "Purchase Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TDS Amount"; TDSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
                Caption = 'TDS Amount';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetTDSAmount()
    var
        TDSStatsManagement: Codeunit "TDS Stats Management";
    begin
        TDSAmount := TDSStatsManagement.GetTDSStatsAmount();
        Calculated := true;
        TDSStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTDSAmount();
    end;

    var

        TDSAmount: Decimal;
        Calculated: Boolean;
}