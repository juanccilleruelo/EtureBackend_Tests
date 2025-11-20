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
      const LOCAL_PATH          = '/datatypes';
      const TEST_DATA_TYPE_CODE = 'TEXT';
      const TEST_DATA_TYPE_NAME = 'Text';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillDataTypeData(ADataSet :TWebClientDataSet; const ACode, AName :string);
      [async] function HasTestDataType:Boolean;
      [async] procedure EnsureTestDataTypeExists;
      [async] procedure DeleteTestDataTypeIfExists;
   published
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
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
   NewField.FieldName   := 'DS_DATA_TYPE';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestDataTypes.FillDataTypeData(ADataSet :TWebClientDataSet; const ACode, AName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_DATA_TYPE').AsString := ACode;
   ADataSet.FieldByName('DS_DATA_TYPE').AsString := AName;
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
                       TEST_DATA_TYPE_NAME);
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
      Assert.IsTrue(DataSet.FieldByName('DS_DATA_TYPE').AsString = TEST_DATA_TYPE_NAME, 'Data type English name matches expected value');
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

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestDataTypes);

end.
