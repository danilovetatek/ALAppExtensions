codeunit 139566 "Shpfy Payments Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestImportPayment()
    var
        PaymentTransaction: Record "Shpfy Payment Transaction";
        Payments: Codeunit "Shpfy Payments";
        Id: BigInteger;
        LastPayoutId: BigInteger;
        JPayment: JsonToken;
    begin
        // [SCENARIO] Extract the data out json token that contains a payment info into the "Shpfy Payment Transaction" record.
        // [GIVEN] A random Generated Payment
        Id := Any.IntegerInRange(10000, 99999);
        JPayment := GetRandomPaymentAsJsonToken(Id);

        // [WHEN] Invoke the function ImportPayment(JFulfillment)
        Payments.ImportPaymentTransaction(JPayment, LastPayoutId);

        // [THEN] We must find the "Shpfy Payment" record with the same id
        LibraryAssert.IsTrue(PaymentTransaction.Get(Id), 'Get "Shpfy Payment Transaction" record');
    end;

    local procedure GetRandomPaymentAsJsonToken(id: BigInteger): JsonToken
    var
        JPayment: JsonObject;
        PaymentGidTxt: Label 'gid://shopify/Payment/%1', Comment = '%1 = id', Locked = true;
        Amount: Decimal;
        Fee: Decimal;
    begin
        Amount := Any.DecimalInRange(100, 2);
        Fee := Any.DecimalInRange(Round(Amount, 1, '<'), 2);
        JPayment.Add('id', id);
        JPayment.Add('admin_graphql_api_id', StrSubstNo(PaymentGidTxt, id));
        JPayment.Add('created_at', Format(CurrentDateTime - 1, 0, 9));
        JPayment.Add('test', false);
        JPayment.Add('payout_id', Any.IntegerInRange(10000, 99999));
        JPayment.Add('currency', Any.IntegerInRange(10000, 99999));
        JPayment.Add('amount', Amount);
        JPayment.Add('fee', Fee);
        JPayment.Add('net', Amount - Fee);
        JPayment.Add('type', Format(enum::"Shpfy Payment Trans. Type".FromInteger(Any.IntegerInRange(0, 6))));
        JPayment.Add('source_id', Any.IntegerInRange(10000, 99999));
        JPayment.Add('source_order_id', Any.IntegerInRange(10000, 99999));
        JPayment.Add('source_order_transaction_id', Any.IntegerInRange(10000, 99999));
        JPayment.Add('processed_at', Format(CurrentDateTime - 1, 0, 9));
        exit(JPayment.AsToken());
    end;

    [Test]
    procedure UnitTestImportDisputeStatus()
    var
        TestPayments: Codeunit "Shpfy Payments";
        PaymentTransaction: Record "Shpfy Payment Transaction";
        DisputeToken: JsonToken;
        ShpfyPaytransDispStatus: enum::"Shpfy Pay. Trans. Disp. Status";
        finalizedOn: DateTime;
    begin
        // [SCENARIO] Extract the data out json token that contains a Dipsute info into the "Shpfy Payment Transaction" record.
        // [GIVEN] A random Generated Dispute
        Id := Any.IntegerInRange(10000, 99999);
        MockPaymentTransaction(Id, PaymentTransaction);
        DisputeToken := GetRandomDisputeAsJsonToken(Id, ShpfyPaytransDispStatus, finalizedOn);

        // [WHEN] Invoke the function ImportDisputeData(JToken)
        TestPayments.ImportDisputeData(DisputeToken);

        // Assert
        LibraryAssert.IsTrue(PaymentTransaction.get(Id), 'At least one "Shpfy Payment Transaction" record should be found');

        LibraryAssert.AreEqual(ShpfyPaytransDispStatus, PaymentTransaction."Dispute Status", PaymentTransaction."Dispute Status", 'Dispute status should match the generated one');
        LibraryAssert.AreEqual(finalizedOn, PaymentTransaction."Dispute Finalized On", 'Dispute finalized on should match the generated one');
    end;

    local procedure GetRandomDisputeAsJsonToken(id: Guid; var ShpfyPaytransDispStatus: enum::"Shpfy Pay. Trans. Disp. Status"; var finalizedOn: DateTime): JsonToken
    var
        DisputeObject: JsonObject;
    begin
        ShpfyPaytransDispStatus := Enum::"Shpfy Pay. Trans. Disp. Status".FromInteger(Any.IntegerInRange(0, 6));
        finalizedOn := CurrentDateTime - 1;

        DisputeObject.Add('id', id);
        DisputeObject.Add('order_id', Any.IntegerInRange(10000, 99999));
        DisputeObject.Add('type', 'chargeback');
        DisputeObject.Add('amount', Any.DecimalInRange(100, 2););
        DisputeObject.Add('currency', Any.IntegerInRange(10000, 99999));
        DisputeObject.Add('reason', 'fraudulent');
        DisputeObject.Add('network_reason_code', Any.IntegerInRange(10000, 99999));
        DisputeObject.Add('status', Format(ShpfyPaytransDispStatus));
        DisputeObject.Add('evidence_due_by', Format(CurrentDateTime - 1, 0, 9));
        DisputeObject.Add('evidence_sent_on', Format(CurrentDateTime - 1, 0, 9));
        DisputeObject.Add('finalized_on', Format(finalizedOn, 0, 9));
        DisputeObject.Add('initiated_at', Format(CurrentDateTime - 1, 0, 9));

        exit(DisputeObject.AsToken());
    end;

    local procedure MockPaymentTransaction(Id: Guid; var PaymentTransaction: Record "Shpfy Payment Transaction")
    begin
        PaymentTransaction.Init();
        PaymentTransaction.Id := Id;
        PaymentTransaction.Insert();
    end;
}