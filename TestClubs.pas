unit TestClubs;

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
   TTestClubs = class(TObject)
   private
      const LOCAL_PATH          = '/clubs';
      const TEST_USER_CODE      = 'UT_CLUB_0001';
      const TEST_USER_NAME      = 'Unit Test Club User';
      const UPDATED_USER_NAME   = 'Unit Test Club User - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillClubData(ADataSet :TWebClientDataSet; const AUserName :string);
      [async] function HasTestClub:Boolean;
      [async] procedure EnsureTestClubExists;
      [async] procedure DeleteTestClubIfExists;
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
   senCille.DataManagement;

{ TTestClubs }

function TTestClubs.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_USER';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_USER';
   NewField.Size := 70;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_PROFILE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'BIRTH_DATE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName := 'CURRENT_AGE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PHONE_NUMBER';
   NewField.Size := 20;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'EMAIL';
   NewField.Size := 100;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'STATE';
   NewField.Size := 1;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'PAST_ILLNESSES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'PHARMACOLOGICAL_TREATMENTS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'ALLERGIES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'SIGNIFICANT_INJURIES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'ORTHOPEDIC_PROBLEMS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'FAMILY_HISTORY';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'AUSCULTATION_FINFINDS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'OTHER_CONTROLS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'OBSERVATIONS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestClubs.FillClubData(ADataSet :TWebClientDataSet; const AUserName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_USER_CODE;
   ADataSet.FieldByName('DS_USER').AsString := AUserName;
   ADataSet.FieldByName('IMG_PROFILE').AsString := 'NoImage';
   ADataSet.FieldByName('BIRTH_DATE').AsDateTime := EncodeDate(1995, 5, 15);
   ADataSet.FieldByName('CURRENT_AGE').AsInteger := 28;
   ADataSet.FieldByName('PHONE_NUMBER').AsString := '+1-555-0100';
   ADataSet.FieldByName('EMAIL').AsString := 'unit.test.club.user@example.com';
   ADataSet.FieldByName('STATE').AsString := 'A';
   ADataSet.FieldByName('PAST_ILLNESSES').AsString := 'None';
   ADataSet.FieldByName('PHARMACOLOGICAL_TREATMENTS').AsString := 'None';
   ADataSet.FieldByName('ALLERGIES').AsString := 'None';
   ADataSet.FieldByName('SIGNIFICANT_INJURIES').AsString := 'None';
   ADataSet.FieldByName('ORTHOPEDIC_PROBLEMS').AsString := 'None';
   ADataSet.FieldByName('FAMILY_HISTORY').AsString := 'No relevant history';
   ADataSet.FieldByName('AUSCULTATION_FINFINDS').AsString := 'Normal';
   ADataSet.FieldByName('OTHER_CONTROLS').AsString := 'Routine checks';
   ADataSet.FieldByName('OBSERVATIONS').AsString := 'Record created for automated unit testing.';
   ADataSet.Post;
end;

[async] function TTestClubs.HasTestClub:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestClubs.EnsureTestClubExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestClub()) then Exit;

   DataSet := CreateDataSet;
   try
      FillClubData(DataSet, TEST_USER_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestClubExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestClubs.DeleteTestClubIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestClubs.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestClubIfExists());

   DataSet := CreateDataSet;
   try
      FillClubData(DataSet, TEST_USER_NAME);
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

[Test] [async] procedure TTestClubs.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestClubExists());

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
      Assert.IsTrue(DataSet.Locate('CD_USER', TEST_USER_CODE, []), 'Test club located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClubs.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClubExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_USER').AsString = TEST_USER_NAME, 'Club user name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClubs.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestClubExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_USER', 'DS_USER', []));
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

[Test] [async] procedure TTestClubs.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClubExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_USER').AsString := UPDATED_USER_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE], ['OLD_CD_USER', TEST_USER_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_USER').AsString = UPDATED_USER_NAME, 'Updated user name stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_USER').AsString := TEST_USER_NAME;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE], ['OLD_CD_USER', TEST_USER_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClubs.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestClubExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test club should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClubs.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClubExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Club successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClubs.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestClubs);

end.
