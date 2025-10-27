unit TestMyVisaTemplates;

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
   TTestMyVisaTemplates = class(TObject)
   private
      const LOCAL_PATH         = '/myvisatemplates';
      const TEST_DOC_TYPE      = 'UT_TEMPLATE_DOC';
      const TEST_IMAGE_DATA    = 'Unit Test Template Content';
      const UPDATED_IMAGE_DATA = 'Updated Unit Test Template Content';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillTemplateData(ADataSet :TWebClientDataSet; const ADocType, AImageData :string);
      [async] function HasTestTemplate:Boolean;
      [async] procedure EnsureTestTemplateExists;
      [async] procedure DeleteTestTemplateIfExists;
      [async] function CallExistsTemplate(const DocType :string):Boolean;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetDocTypes;
      [Test] [async] procedure TestExistsTemplate;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestMyVisaTemplates }

function TTestMyVisaTemplates.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DOC_TYPE';
   NewField.Size        := 40;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_DOCUMENT';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestMyVisaTemplates.FillTemplateData(ADataSet :TWebClientDataSet; const ADocType, AImageData :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('DOC_TYPE').AsString      := ADocType;
   ADataSet.FieldByName('IMG_DOCUMENT').AsString  := AImageData;
   ADataSet.Post;
end;

[async] function TTestMyVisaTemplates.HasTestTemplate:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['DOC_TYPE', TEST_DOC_TYPE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMyVisaTemplates.EnsureTestTemplateExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestTemplate()) then Exit;

   DataSet := CreateDataSet;
   try
      FillTemplateData(DataSet,
                       TEST_DOC_TYPE,
                       TEST_IMAGE_DATA);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestTemplateExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMyVisaTemplates.DeleteTestTemplateIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]]));
   except
      on E:Exception do ;
   end;
end;

[async] function TTestMyVisaTemplates.CallExistsTemplate(const DocType :string):Boolean;
var Request      :TWebHttpRequest;
    Response     :TJSXMLHttpRequest;
    JSONObject   :TJSONObject;
    ResponseJSON :TJSONValue;
    ResponseText :string;
    JSONObj      :TJSONObject;
    JSONString   :string;
begin
   Result := False;
   Request := TWebHttpRequest.Create(nil);
   JSONObject := TJSONObject.Create;
   try
      JSONObject.AddPair('DOC_TYPE', DocType);
      Request.URL := TMVCReq.Host + LOCAL_PATH + '/existstemplate';
      //Request.Method := 'POST';
      Request.Headers.Add('Content-Type=application/json');
      Request.PostData := JSONObject.ToJSON;

      Response := await(TJSXMLHttpRequest, Request.Perform);
      Assert.IsTrue(Response.Status = 200, 'ExistsTemplate must answer HTTP 200');

      ResponseText := Trim(string(Response.ResponseText));
      if ResponseText = '' then Exit(False);

      ResponseJSON := TJSONObject.ParseJSONValue(ResponseText);
      try
         if ResponseJSON is TJSONObject then
         begin
            JSONObj := TJSONObject(ResponseJSON);
            JSONString := LowerCase(JSONObj.ToJSON);
            Result := Pos('"exists":true', JSONString) > 0;
            if not Result then
               Result := Pos('"existstemplate":true', JSONString) > 0;
            if not Result then
               Result := Pos('true', JSONString) > 0;
         end
         else
            Result := Pos('true', LowerCase(ResponseText)) > 0;
      finally
         ResponseJSON.Free;
      end;
   finally
      JSONObject.Free;
      Request.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestTemplateIfExists());

   DataSet := CreateDataSet;
   try
      FillTemplateData(DataSet,
                       TEST_DOC_TYPE,
                       TEST_IMAGE_DATA);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestTemplate()), 'Inserted template not found afterwards');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTemplateExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['DOC_TYPE', TEST_DOC_TYPE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('IMG_DOCUMENT').AsString = TEST_IMAGE_DATA,
                    'Template image matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestTemplateExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'DOC_TYPE', 'DOC_TYPE', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 templates');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTemplateExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('IMG_DOCUMENT').AsString := UPDATED_IMAGE_DATA;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('IMG_DOCUMENT').AsString = UPDATED_IMAGE_DATA,
                    'Updated template stored in database');

      DataSet.Edit;
      DataSet.FieldByName('IMG_DOCUMENT').AsString := TEST_IMAGE_DATA;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestDelete;
var ExceptMsg :string;
begin
   await(EnsureTestTemplateExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);
   Assert.IsFalse(await(Boolean, HasTestTemplate()), 'Template must not exist after deletion');

   await(DeleteTestTemplateIfExists());
end;

[Test] [async] procedure TTestMyVisaTemplates.TestGetDocTypes;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestTemplateExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getdoctypes', 'DOC_TYPE', 'DOC_TYPE', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetDocTypes -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 document types');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaTemplates.TestExistsTemplate;
var Exists :Boolean;
begin
   await(EnsureTestTemplateExists());

   Exists := await(Boolean, CallExistsTemplate(TEST_DOC_TYPE));
   Assert.IsTrue(Exists, 'ExistsTemplate must return true for an existing template');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestMyVisaTemplates);
end.
