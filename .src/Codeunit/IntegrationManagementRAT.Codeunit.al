namespace RAT.Integration;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Address;
using System.Text;

codeunit 90000 "Integration Management RAT"
{
    var
        RecordRef: RecordRef;
        AccountDetails: JsonObject;
        JsonBody: Text;

    trigger OnRun()
    begin
        this.AccountList();
    end;

    procedure AccountList()
    var
        Customer: Record Customer;
    begin
        Customer.Reset();
        //put your filter here
        if Customer.FindSet() then
            repeat
                Clear(this.AccountDetails);
                this.AccountBody(Customer);
                this.RecordRef.GetTable(Customer);
                this.HttpRequestPOSTWithBasicAuthV2()
            until Customer.Next() = 0;
    end;

    procedure AccountBody(Customer: Record Customer)
    var
        lRec_Country: Record "Country/Region";
    begin
        this.AccountDetails.Add('u_name', Customer.Name);
        this.AccountDetails.Add('u_account_id', Customer."No.");
        this.AccountDetails.Add('u_street', Customer.Address + ' ' + Customer."Address 2");
        this.AccountDetails.Add('u_city', Customer.City);
        if lRec_Country.Get(Customer."Country/Region Code") then
            this.AccountDetails.Add('u_country', lRec_Country.Name);
        this.AccountDetails.Add('u_salesman_1', Customer."Salesperson Code");
        //Add more fields as needed
        this.AccountDetails.WriteTo(this.JsonBody);
    end;

    [TryFunction]
    procedure HttpRequestPOSTWithBasicAuthV2()
    var
        Customer_Rec: Record Customer;
        IntegrationSetup_Rec: Record "Integration Setup RAT";
        Base64Convert_CU: Codeunit "Base64 Convert";
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Response_Txt: Text;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
    begin
        IntegrationSetup_Rec.Get();
        if IntegrationSetup_Rec."Show Payload" then
            if GuiAllowed then
                if not Confirm(this.JsonBody, false) then
                    Error(this.JsonBody);
        case this.RecordRef.NUMBER of
            Database::Customer:
                begin
                    this.RecordRef.GetTable(Customer_Rec);
                    RequestMessage.SetRequestUri(IntegrationSetup_Rec."Endpoint 1");
                    RequestMessage.Method('POST')
                end;
        end;
        RequestMessage.GetHeaders(RequestHeaders);

        RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert_CU.ToBase64(IntegrationSetup_Rec."User Name" + ':' + IntegrationSetup_Rec.Password));

        HttpContent.WriteFrom(this.JsonBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        HttpContent.GetHeaders(ContentHeaders);
        RequestMessage.Content(HttpContent);

        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(Response_Txt);
            Message(Response_Txt);
            if ResponseMessage.IsSuccessStatusCode then
                ReadResponsev2(Response_Txt, this.RecordRef);
        end;
        Commit();
    end;

    procedure ReadResponseV2(Response: Text; RecordRef_P: recordref)
    var
        JToken: JsonToken;
        jArr: JsonArray;
        JObject, JObject2 : JsonObject;
        SysId: Text[250];
        status: Text;
    begin
        if Response = '' then
            exit;
        JToken.ReadFrom(Response);
        JObject := JToken.AsObject();
        JObject.SelectToken('result', JToken);
        jArr := JToken.AsArray();
        jArr.Get(0, JToken);
        if JToken.IsObject then
            JObject2 := JToken.AsObject();
        status := GetValueAsText(JToken, 'status');
        if status = 'error' then
            InsertFailureIntgLog(RecordRef_P, GetValueAsText(JToken, 'error_message'))
        else begin
            SysId := GetValueAsText(JToken, 'sys_id');
            InsertSuccessIntgLogV2(RecordRef_P, SysId);
        end;
    end;

    local procedure InsertSuccessIntgLogV2(RecRef: RecordRef; SysId: Text[250])
    var
        SGIIntegrationLog: Record "Integration Log RAT";
        CustomerLVar: Record Customer;
    begin
        SGIIntegrationLog.Init();
        SGIIntegrationLog."Entry No." := FindLastLogEntryNo();
        SGIIntegrationLog."API DateTime" := CurrentDateTime;
        SGIIntegrationLog.Status := SGIIntegrationLog.Status::Success;

        case RecRef.Number of
            database::Customer:
                begin
                    RecRef.SetTable(CustomerLVar);
                    SGIIntegrationLog."Source Record" := CustomerLVar.RecordId;
                    //you can also log the sys_id back to your source record here by doing an update on the Customer table using the RecordRef
                    // if needed, since you have the RecId of the source record in hand, you can easily do that.
                    CustomerLVar.Modify(false);
                end;
        end;
        SGIIntegrationLog.Insert();
        RecRef.Close();
    end;

    local procedure InsertFailureIntgLog(RecordRefLVar: RecordRef; Errormessage: Text)
    var
        SGIIntegrationLog: Record "Integration Log RAT";
        CustomerLVar: Record Customer;
    begin
        SGIIntegrationLog.Init();
        SGIIntegrationLog."Entry No." := FindLastLogEntryNo();
        SGIIntegrationLog."API DateTime" := CurrentDateTime;
        SGIIntegrationLog.Status := SGIIntegrationLog.Status::Failed;
        SGIIntegrationLog."Error Message" := CopyStr(Errormessage, 1, 2000);

        case RecordRefLVar.Number of
            database::Customer:
                begin
                    RecordRefLVar.SetTable(customerLVar);
                    SGIIntegrationLog."Source Record" := customerLVar.RecordId;
                end;
        end;
        SGIIntegrationLog.Insert();
    end;

    procedure GetValueAsText(JToken: JsonToken; ParamString: Text): Text[250]
    var
        JObject: JsonObject;
    begin
        JObject := JToken.AsObject();
        exit(SelectJsonToken(JObject, ParamString));
    end;

    procedure SelectJsonToken(JObject: JsonObject; Path: Text): Text[250]
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if NOT JToken.AsValue().IsNull() then
                exit(Format(JToken.AsValue().AsText()));
    end;

    local procedure FindLastLogEntryNo(): Integer
    var
        SGIIntegrationLog: Record "Integration Log RAT";
        EntryNo: Integer;
    begin
        SGIIntegrationLog.Reset();
        if SGIIntegrationLog.FindLast() then
            EntryNo += SGIIntegrationLog."Entry No." + 1
        else
            EntryNo := 1;
        exit(EntryNo);
    end;


}
