unit TestCallUps;

interface

uses
   WEBLib.UnitTesting.Classes,
   System.SysUtils, System.Classes, System.DateUtils, JS, Web,
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
   TTestCallUps = class(TObject)
   private
      const LOCAL_PATH            = '/callups';
      const TEST_TEAM_CODE        = 'UT_TEAM_0001';
      const TEST_CALL_UP_DATE_ISO = '2025-03-15T10:30:00';
      const TEST_MATCH            = 'Unit Test Friendly Match';
      const UPDATED_MATCH         = 'Unit Test Friendly Match - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillCallUpData(ADataSet :TWebClientDataSet; const AMatch :string);
      [async] function HasTestCallUp:Boolean;
      [async] procedure EnsureTestCallUpExists;
      [async] procedure DeleteTestCallUpIfExists;
      function CallUpDate: TDateTime;
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

{ TTestCallUps }

function TTestCallUps.CallUpDate:TDateTime;
begin
   Result := ISO8601ToDate(TEST_CALL_UP_DATE_ISO);
end;

function TTestCallUps.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_TEAM';
   NewField.Size        := 14;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'DT_CALL_UP';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_TEAM';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'MATCH';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'MEETING_POINT';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'LOCATION';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'TRANSPORTATION';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'TRAVEL_BY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'UNIFORM';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'NOTES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestCallUps.FillCallUpData(ADataSet :TWebClientDataSet; const AMatch :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_TEAM').AsString          := TEST_TEAM_CODE;
   ADataSet.FieldByName('DT_CALL_UP').AsDateTime     := CallUpDate;
   ADataSet.FieldByName('DS_TEAM').AsString          := 'Unit Test Team';
   ADataSet.FieldByName('MATCH').AsString            := AMatch;
   ADataSet.FieldByName('MEETING_POINT').AsString    := 'Training Center';
   ADataSet.FieldByName('LOCATION').AsString         := 'Unit Test City';
   ADataSet.FieldByName('TRANSPORTATION').AsString   := 'Bus';
   ADataSet.FieldByName('TRAVEL_BY').AsString        := 'Coach';
   ADataSet.FieldByName('UNIFORM').AsString          := 'Home Kit';
   ADataSet.FieldByName('NOTES').AsString            := 'Generated from automated unit testing.';
   ADataSet.Post;
end;

[async] function TTestCallUps.HasTestCallUp:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE],
                           ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCallUps.EnsureTestCallUpExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestCallUp()) then Exit;

   DataSet := CreateDataSet;
   try
      FillCallUpData(DataSet, TEST_MATCH);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCallUpExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCallUps.DeleteTestCallUpIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestCallUps.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestCallUpIfExists());

   DataSet := CreateDataSet;
   try
      FillCallUpData(DataSet, TEST_MATCH);
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

[Test] [async] procedure TTestCallUps.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestCallUpExists());

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
      Assert.IsTrue(DataSet.Locate('CD_TEAM', TEST_TEAM_CODE, []) and
                    (FormatDateTime('yyyymmddhhnnss', DataSet.FieldByName('DT_CALL_UP').AsDateTime) =
                     FormatDateTime('yyyymmddhhnnss', CallUpDate)),
                    'Test call-up located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCallUps.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCallUpExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE],
                           ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('MATCH').AsString = TEST_MATCH, 'Match name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCallUps.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestCallUpExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_TEAM', 'DS_TEAM', []));
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

[Test] [async] procedure TTestCallUps.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCallUpExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('MATCH').AsString := UPDATED_MATCH;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE],
                           ['OLD_CD_TEAM', TEST_TEAM_CODE],
                           ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO],
                           ['OLD_DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('MATCH').AsString = UPDATED_MATCH, 'Updated match stored in database');

      DataSet.Edit;
      DataSet.FieldByName('MATCH').AsString := TEST_MATCH;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['OLD_CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO],
                        ['OLD_DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCallUps.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestCallUpExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test call-up should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCallUps.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCallUpExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['DT_CALL_UP', TEST_CALL_UP_DATE_ISO]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Call-up successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCallUps.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCallUps);

end.
