unit TestProperties;

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
   TTestProperties = class(TObject)
   private
      const LOCAL_PATH              = '/properties';
      const TEST_PROPERTY_CODE      = 'UT_PROPERTY_0001';
      const TEST_PROPERTY_NAME      = 'Unit Test Property';
      const UPDATED_PROPERTY_NAME   = 'Unit Test Property Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillPropertyData(ADataSet :TWebClientDataSet; const ACode, AName :string);
      [async] function HasTestProperty:Boolean;
      [async] procedure EnsureTestPropertyExists;
      [async] procedure DeleteTestPropertyIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestProperties }

function TTestProperties.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_PROPERTY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_PROPERTY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ADDRESS_LN_1';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ADDRESS_LN_2';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CITY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'POSTAL_CODE';
   NewField.Size        := 15;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PROVINCE';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_STATE';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_COUNTRY';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PHONE_NUMBER';
   NewField.Size        := 256;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TFloatField.Create(Result);
   NewField.FieldName   := 'MONTHLY_RENT';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftFloat, 0);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName   := 'NUMBER_OF_BEDS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'NOTES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_PROFILE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestProperties.FillPropertyData(ADataSet :TWebClientDataSet; const ACode, AName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_PROPERTY').AsString     := ACode;
   ADataSet.FieldByName('DS_PROPERTY').AsString     := AName;
   ADataSet.FieldByName('ADDRESS_LN_1').AsString   := '123 Unit Test Street';
   ADataSet.FieldByName('ADDRESS_LN_2').AsString   := 'Suite 456';
   ADataSet.FieldByName('CITY').AsString           := 'Testville';
   ADataSet.FieldByName('POSTAL_CODE').AsString    := '12345';
   ADataSet.FieldByName('PROVINCE').AsString       := 'Test Province';
   ADataSet.FieldByName('CD_STATE').AsString       := 'UT';
   ADataSet.FieldByName('CD_COUNTRY').AsString     := 'UTC';
   ADataSet.FieldByName('PHONE_NUMBER').AsString   := '+1-800-555-0100';
   ADataSet.FieldByName('MONTHLY_RENT').AsFloat    := 1250.50;
   ADataSet.FieldByName('NUMBER_OF_BEDS').AsInteger := 4;
   ADataSet.FieldByName('NOTES').AsString          := 'Property created for automated unit testing.';
   ADataSet.FieldByName('IMG_PROFILE').AsString    := 'UnitTestImageData';
   ADataSet.Post;
end;

[async] function TTestProperties.HasTestProperty:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestProperties.EnsureTestPropertyExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestProperty()) then Exit;

   DataSet := CreateDataSet;
   try
      FillPropertyData(DataSet,
                       TEST_PROPERTY_CODE,
                       TEST_PROPERTY_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestPropertyExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestProperties.DeleteTestPropertyIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_PROPERTY', TEST_PROPERTY_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestProperties.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestPropertyIfExists());

   DataSet := CreateDataSet;
   try
      FillPropertyData(DataSet,
                       TEST_PROPERTY_CODE,
                       TEST_PROPERTY_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestProperty()), 'Inserted property not found afterwards');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPropertyExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'],
                         ['SearchText', TEST_PROPERTY_CODE],
                         ['OrderField', '']],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Select returned at least one row');
      Assert.IsTrue(DataSet.Locate('CD_PROPERTY', TEST_PROPERTY_CODE, []), 'Test property located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPropertyExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_PROPERTY').AsString = TEST_PROPERTY_NAME, 'Property name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestPropertyExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_PROPERTY', 'DS_PROPERTY', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(TMisc.ListContains(Items, TEST_PROPERTY_CODE), 'Test property present in GetAll list');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPropertyExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_PROPERTY').AsString := UPDATED_PROPERTY_NAME;
      DataSet.FieldByName('MONTHLY_RENT').AsFloat := 1500.75;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_PROPERTY', TEST_PROPERTY_CODE],
                           ['OLD_CD_PROPERTY', TEST_PROPERTY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_PROPERTY').AsString = UPDATED_PROPERTY_NAME, 'Updated property name stored');
      Assert.IsTrue(Abs(DataSet.FieldByName('MONTHLY_RENT').AsFloat - 1500.75) < 0.01, 'Updated monthly rent stored');

      DataSet.Edit;
      DataSet.FieldByName('DS_PROPERTY').AsString := TEST_PROPERTY_NAME;
      DataSet.FieldByName('MONTHLY_RENT').AsFloat := 1250.50;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_PROPERTY', TEST_PROPERTY_CODE],
                        ['OLD_CD_PROPERTY', TEST_PROPERTY_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestPropertyExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test property should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPropertyExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_PROPERTY', TEST_PROPERTY_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_PROPERTY', TEST_PROPERTY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Property successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestProperties.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getorderbyfields', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Order by fields available');
   finally
      Items.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestProperties);

end.
