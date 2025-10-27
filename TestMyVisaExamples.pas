unit TestMyVisaExamples;

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
   TTestMyVisaExamples = class(TObject)
   private
      const LOCAL_PATH            = '/myvisaexamples';
      const TEST_DOC_TYPE         = 'UT_MYVISA_DOC_0001';
      const TEST_IMAGE_CONTENT    = 'UnitTestImagePayload';
      const UPDATED_IMAGE_CONTENT = 'UnitTestImagePayloadUpdated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillExampleData(ADataSet :TWebClientDataSet; const ADocType, AImageContent :string);
      [async] function HasTestExample:Boolean;
      [async] procedure EnsureTestExampleExists;
      [async] procedure DeleteTestExampleIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestExistsExample;
   end;
{$M-}

implementation

uses
   senCille.DataManagement;

{ TTestMyVisaExamples }

function TTestMyVisaExamples.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DOC_TYPE';
   NewField.Size := 40;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_DOCUMENT';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestMyVisaExamples.FillExampleData(ADataSet :TWebClientDataSet; const ADocType, AImageContent :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('DOC_TYPE').AsString := ADocType;
   ADataSet.FieldByName('IMG_DOCUMENT').AsString := AImageContent;
   ADataSet.Post;
end;

[async] function TTestMyVisaExamples.HasTestExample:Boolean;
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

[async] procedure TTestMyVisaExamples.EnsureTestExampleExists;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestExample()) then Exit;

   DataSet := CreateDataSet;
   try
      FillExampleData(DataSet, TEST_DOC_TYPE, TEST_IMAGE_CONTENT);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestExampleExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMyVisaExamples.DeleteTestExampleIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestInsert;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestExampleIfExists());

   DataSet := CreateDataSet;
   try
      FillExampleData(DataSet, TEST_DOC_TYPE, TEST_IMAGE_CONTENT);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestGetOne;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestExampleExists());

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
      Assert.IsTrue(DataSet.FieldByName('DOC_TYPE').AsString = TEST_DOC_TYPE, 'Doc type matches expected value');
      Assert.IsTrue(DataSet.FieldByName('IMG_DOCUMENT').AsString = TEST_IMAGE_CONTENT, 'Image content matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestGetAll;
var Items :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestExampleExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'DOC_TYPE', 'DOC_TYPE', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestUpdate;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestExampleExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('IMG_DOCUMENT').AsString := UPDATED_IMAGE_CONTENT;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE], ['OLD_DOC_TYPE', TEST_DOC_TYPE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('IMG_DOCUMENT').AsString = UPDATED_IMAGE_CONTENT, 'Updated image stored in database');

      DataSet.Edit;
      DataSet.FieldByName('IMG_DOCUMENT').AsString := TEST_IMAGE_CONTENT;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE], ['OLD_DOC_TYPE', TEST_DOC_TYPE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestDelete;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestExampleExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_TYPE', TEST_DOC_TYPE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Example successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaExamples.TestExistsExample;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
    ExistsRecord :Boolean;
    TextMessage :string;
begin
   await(EnsureTestExampleExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['DOC_TYPE', TEST_DOC_TYPE]],
                       DataSet));
      try
         ExistsRecord := await(Boolean, TDB.CheckExistence(LOCAL_PATH+'/existsexample', DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
            ExistsRecord := False;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in ExistsExample -> '+ExceptMsg);
      Assert.IsTrue(ExistsRecord = True, 'Test example should exist');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestMyVisaExamples);

end.
