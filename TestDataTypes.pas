unit TestDataTypes;

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
   TTestDataTypes = class(TObject)
   private
      const LOCAL_PATH              = '/datatypes';
      const TEST_DATA_TYPE_CODE     = 'UT_DATATYPE1';
      const TEST_DATA_TYPE_NAME_ES  = 'Tipo de Dato Prueba';
      const TEST_DATA_TYPE_NAME_EN  = 'Unit Test Data Type';
      const UPDATED_DATA_TYPE_ES    = 'Tipo de Dato Actualizado';
      const UPDATED_DATA_TYPE_EN    = 'Updated Unit Test Data Type';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillDataTypeData(ADataSet :TWebClientDataSet; const ACode, ANameEs, ANameEn :string);
      [async] function HasTestDataType:Boolean;
      [async] procedure EnsureTestDataTypeExists;
      [async] procedure DeleteTestDataTypeIfExists;
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

{ TTestDataTypes }

function TTestDataTypes.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_DATA_TYPE';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_DATA_TYPE_ES';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_DATA_TYPE_EN';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestDataTypes.FillDataTypeData(ADataSet :TWebClientDataSet; const ACode, ANameEs, ANameEn :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_DATA_TYPE').AsString   := ACode;
   ADataSet.FieldByName('DS_DATA_TYPE_ES').AsString := ANameEs;
   ADataSet.FieldByName('DS_DATA_TYPE_EN').AsString := ANameEn;
   ADataSet.Post;
end;

[async] function TTestDataTypes.HasTestDataType:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestDataTypes.EnsureTestDataTypeExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestDataType()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillDataTypeData(DataSet,
                       TEST_DATA_TYPE_CODE,
                       TEST_DATA_TYPE_NAME_ES,
                       TEST_DATA_TYPE_NAME_EN);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestDataTypeExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestDataTypes.DeleteTestDataTypeIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestDataTypeIfExists());

   DataSet := CreateDataSet;
   try
      FillDataTypeData(DataSet,
                       TEST_DATA_TYPE_CODE,
                       TEST_DATA_TYPE_NAME_ES,
                       TEST_DATA_TYPE_NAME_EN);
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

[Test] [async] procedure TTestDataTypes.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestDataTypeExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'        ],
                         ['SearchText', 'Unit Test'],
                         ['OrderField', ''         ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_DATA_TYPE', TEST_DATA_TYPE_CODE, []), 'Test data type located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestDataTypeExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_DATA_TYPE_EN').AsString = TEST_DATA_TYPE_NAME_EN, 'Data type English name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestDataTypeExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_DATA_TYPE', 'DS_DATA_TYPE_EN', []));
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

[Test] [async] procedure TTestDataTypes.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestDataTypeExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_DATA_TYPE_ES').AsString := UPDATED_DATA_TYPE_ES;
      DataSet.FieldByName('DS_DATA_TYPE_EN').AsString := UPDATED_DATA_TYPE_EN;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE], ['OLD_CD_DATA_TYPE', TEST_DATA_TYPE_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_DATA_TYPE_ES').AsString = UPDATED_DATA_TYPE_ES, 'Updated Spanish description stored in database');
      Assert.IsTrue(DataSet.FieldByName('DS_DATA_TYPE_EN').AsString = UPDATED_DATA_TYPE_EN, 'Updated English description stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_DATA_TYPE_ES').AsString := TEST_DATA_TYPE_NAME_ES;
      DataSet.FieldByName('DS_DATA_TYPE_EN').AsString := TEST_DATA_TYPE_NAME_EN;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE], ['OLD_CD_DATA_TYPE', TEST_DATA_TYPE_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestDataTypeExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test data type should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestDataTypeExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_DATA_TYPE', TEST_DATA_TYPE_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Data type successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDataTypes.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestDataTypes);

end.
