unit TestMailTemplates;

interface

uses
   WEBLib.UnitTesting.Classes,
   System.SysUtils, System.Classes, JS, Web,
   Vcl.Controls, Vcl.StdCtrls,
   Data.DB,
   WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs, WEBLib.ExtCtrls,
   WEBLib.DBCtrls, WEBLib.StdCtrls, WEBLib.ComCtrls, WEBLib.REST,
   WEBLib.DB, WEBLib.CDS, WebLib.JSON,
   WEBLib.WebCtrls, WEBLib.Menus, WEBLib.Grids, DB,
   senCille.Miscellaneous,
   senCille.MVCRequests;

type
{$M+}
   [TestFixture]
   TTestMailTemplates = class(TObject)
   private
      const LOCAL_PATH             = '/mailtemplates';
      const TEST_TEMPLATE_CODE     = 'UT_MAIL_TEMPLATE_0001';
      const TEST_TEMPLATE_DESC     = 'Unit Test Mail Template';
      const UPDATED_TEMPLATE_DESC  = 'Unit Test Mail Template - Updated';
      const TEST_TEMPLATE_BODY     = '<p>Hello {{PlayerName}}</p>';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillMailTemplateData(ADataSet :TWebClientDataSet;
                                     const ADescription :string;
                                     const ATemplateBody :string;
                                     const AMailerCode :string;
                                     const AMailerDescription :string);
      [async] function HasTestMailTemplate:Boolean;
      [async] procedure EnsureTestMailTemplateExists;
      [async] procedure DeleteTestMailTemplateIfExists;
      [async] procedure EnsureMailerInfo(var AMailerCode :string; var AMailerDescription :string);
      function BuildURL(const AResource :string):string;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
      [Test] [async] procedure TestGetAllMailers;
      [Test] [async] procedure TestReplacePlaceholders;
      [Test] [async] procedure TestSendEmail;
   end;
{$M-}

implementation

uses
   senCille.DataManagement,
   senCille.WebSetup;

{ TTestMailTemplates }

function TTestMailTemplates.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_MAIL_TEMPLATE';
   NewField.Size := 15;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_MAIL_TEMPLATE';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_MAILER';
   NewField.Size := 15;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_MAILER';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'TEMPLATE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestMailTemplates.FillMailTemplateData(ADataSet :TWebClientDataSet;
                                                  const ADescription :string;
                                                  const ATemplateBody :string;
                                                  const AMailerCode :string;
                                                  const AMailerDescription :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_MAIL_TEMPLATE').AsString := TEST_TEMPLATE_CODE;
   ADataSet.FieldByName('DS_MAIL_TEMPLATE').AsString := ADescription;
   ADataSet.FieldByName('CD_MAILER').AsString := AMailerCode;
   ADataSet.FieldByName('DS_MAILER').AsString := AMailerDescription;
   ADataSet.FieldByName('TEMPLATE').AsString := ATemplateBody;
   ADataSet.Post;
end;

[async] function TTestMailTemplates.HasTestMailTemplate:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                          DataSet));
      except
         on E:Exception do begin
            if DataSet.Active then begin
               DataSet.EmptyDataSet;
            end;
         end;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMailTemplates.EnsureTestMailTemplateExists;
var DataSet           :TWebClientDataSet;
    ExceptMsg         :string;
    MailerCode        :string;
    MailerDescription :string;
begin
   if await(Boolean, HasTestMailTemplate()) then begin
      Exit;
   end;

   await(EnsureMailerInfo(MailerCode, MailerDescription));

   DataSet := CreateDataSet;
   try
      FillMailTemplateData(DataSet, TEST_TEMPLATE_DESC, TEST_TEMPLATE_BODY, MailerCode, MailerDescription);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestMailTemplateExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMailTemplates.DeleteTestMailTemplateIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[async] procedure TTestMailTemplates.EnsureMailerInfo(var AMailerCode :string; var AMailerDescription :string);
var JSONArray :TJSONArray;
    ExceptMsg :string;
    jo        :TJSONObject;
begin
   JSONArray := nil;
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getallmailers'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
      end;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'EnsureMailerInfo -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'EnsureMailerInfo -> No mailers available');

   jo := TJSONObject(JSONArray.Items[0]);
   AMailerCode := jo.GetJSONValue('CD_MAILER');
   AMailerDescription := jo.GetJSONValue('DS_MAILER');

   Assert.IsTrue(AMailerCode <> '', 'EnsureMailerInfo -> Empty mailer code');
end;

function TTestMailTemplates.BuildURL(const AResource :string):string;
begin
   Result := TMVCReq.Host + LOCAL_PATH + AResource;
end;

[Test] [async] procedure TTestMailTemplates.TestInsert;
var DataSet           :TWebClientDataSet;
    ExceptMsg         :string;
    MailerCode        :string;
    MailerDescription :string;
begin
   await(DeleteTestMailTemplateIfExists());
   await(EnsureMailerInfo(MailerCode, MailerDescription));

   DataSet := CreateDataSet;
   try
      FillMailTemplateData(DataSet, TEST_TEMPLATE_DESC, TEST_TEMPLATE_BODY, MailerCode, MailerDescription);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestMailTemplateExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'             ],
                         ['SearchText', 'Unit Test'      ],
                         ['OrderField', 'DS_MAIL_TEMPLATE']],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE, []), 'Test mail template located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestMailTemplateExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_MAIL_TEMPLATE').AsString = TEST_TEMPLATE_DESC, 'Template description matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestMailTemplateExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_MAIL_TEMPLATE', 'DS_MAIL_TEMPLATE', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestMailTemplateExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_MAIL_TEMPLATE').AsString := UPDATED_TEMPLATE_DESC;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE],
                           ['OLD_CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_MAIL_TEMPLATE').AsString = UPDATED_TEMPLATE_DESC, 'Updated description stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_MAIL_TEMPLATE').AsString := TEST_TEMPLATE_DESC;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE],
                        ['OLD_CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    ExceptMsg    :string;
    TextMessage  :string;
    IsReferenced :Boolean;
begin
   await(EnsureTestMailTemplateExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test mail template should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestMailTemplateExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
      end;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Mail template successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getorderbyfields', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Order by fields available');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestGetAllMailers;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   JSONArray := nil;
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getallmailers'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
      end;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllMailers -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'GetAllMailers must provide data');
end;

[Test] [async] procedure TTestMailTemplates.TestReplacePlaceholders;
const PLAYER_NAME = 'Unit Test Player';
var Request     :TWebHttpRequest;
    Response    :TJSXMLHttpRequest;
    Payload     :TJSONObject;
    DataPayload :TJSONObject;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/replaceplaceholders');
      //Request.Method := 'POST';
      Request.Headers.Values['Content-Type'] := 'application/json';

      Payload := TJSONObject.Create;
      try
         Payload.AddPair('Template', TEST_TEMPLATE_BODY);
         DataPayload := TJSONObject.Create;
         try
            DataPayload.AddPair('PlayerName', PLAYER_NAME);
            Payload.AddPair('JSONData', DataPayload.ToString);
         finally
            DataPayload.Free;
         end;
         Request.PostData := Payload.ToString;
      finally
         Payload.Free;
      end;

      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue((Response.Status >= 200) and (Response.Status < 300), 'ReplacePlaceholders must respond with HTTP success.');
      Assert.IsTrue(Pos(PLAYER_NAME, Response.ResponseText) > 0, 'Processed template must contain player name.');
   finally
      Request.Free;
   end;
end;

[Test] [async] procedure TTestMailTemplates.TestSendEmail;
const TARGET_EMAIL = 'unit.test@example.com';
var Request     :TWebHttpRequest;
    Response    :TJSXMLHttpRequest;
    Payload     :TJSONObject;
    Recipients  :TJSONArray;
    DataPayload :TJSONObject;
begin
   await(EnsureTestMailTemplateExists());
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/sendemail');
      //Request.Method := 'POST';
      Request.Headers.Values['Content-Type'] := 'application/json';

      Payload := TJSONObject.Create;
      try
         Payload.AddPair('CD_MAIL_TEMPLATE', TEST_TEMPLATE_CODE);
         DataPayload := TJSONObject.Create;
         try
            DataPayload.AddPair('PlayerName', 'Unit Test Player');
            Payload.AddPair('JSONData', DataPayload.ToString);
         finally
            DataPayload.Free;
         end;
         Recipients := TJSONArray.Create;
         //Recipients.Add(TJSONString.Create(TARGET_EMAIL));
         Payload.AddPair('Recipients', Recipients);
         Request.PostData := Payload.ToString;
      finally
         Payload.Free;
      end;

      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue((Response.Status >= 200) and (Response.Status < 300), 'SendEmail must respond with HTTP success.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'SendEmail must return a response payload.');
   finally
      Request.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestMailTemplates);

end.
