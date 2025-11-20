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
      const LOCAL_PATH        = '/clubs';
      const TEST_CLUB_CODE    = 'UT_CLUB_0001';
      const TEST_CLUB_NAME    = 'Unit Test Club';
      const UPDATED_CLUB_NAME = 'Unit Test Club - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillClubData(ADataSet :TWebClientDataSet; const AClubName :string);
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
   NewField.FieldName := 'CD_CLUB';
   NewField.Size := 12;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_CLUB';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'ADDRESS_LN_1';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'ADDRESS_LN_2';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CITY';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'POSTAL_CODE';
   NewField.Size := 15;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PROVINCE';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_COUNTRY';
   NewField.Size := 3;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_STATE';
   NewField.Size := 3;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PHONE_NUMBER';
   NewField.Size := 20;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'OBSERVATIONS';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'GMAPS_LINK';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_PROFILE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestClubs.FillClubData(ADataSet :TWebClientDataSet; const AClubName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_CLUB'     ).AsString := TEST_CLUB_CODE;
   ADataSet.FieldByName('DS_CLUB'     ).AsString := AClubName;
   ADataSet.FieldByName('ADDRESS_LN_1').AsString := 'Address Line 2';
   ADataSet.FieldByName('ADDRESS_LN_2').AsString := 'Address Line 2';
   ADataSet.FieldByName('CITY'        ).AsString := 'City';
   ADataSet.FieldByName('POSTAL_CODE' ).AsString := '47300';
   ADataSet.FieldByName('PROVINCE'    ).AsString := 'Valladolid';
   ADataSet.FieldByName('CD_STATE'    ).AsString := 'USA';
   ADataSet.FieldByName('CD_COUNTRY'  ).AsString := 'AL';
   ADataSet.FieldByName('PHONE_NUMBER').AsString := 'None';
   ADataSet.FieldByName('OBSERVATIONS').AsString := 'None';
   ADataSet.FieldByName('GMAPS_LINK'  ).AsString := 'None';
   ADataSet.FieldByName('IMG_PROFILE' ).AsString := 'None';
   ADataSet.Post;
end;

[async] function TTestClubs.HasTestClub:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CLUB', TEST_CLUB_CODE]],
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
      FillClubData(DataSet, TEST_CLUB_NAME);
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
      await(TDB.Delete(LOCAL_PATH, [['CD_CLUB', TEST_CLUB_CODE]]));
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
      FillClubData(DataSet, TEST_CLUB_NAME);
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
      Assert.IsTrue(DataSet.Locate('CD_CLUB', TEST_CLUB_CODE, []), 'Test club located in dataset');
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
                          [['CD_CLUB', TEST_CLUB_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_CLUB').AsString = TEST_CLUB_NAME, 'Club name matches expected value');
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
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_CLUB', 'DS_CLUB', []));
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
                       [['CD_CLUB', TEST_CLUB_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_CLUB').AsString := UPDATED_CLUB_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_CLUB', TEST_CLUB_CODE], ['OLD_CD_CLUB', TEST_CLUB_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CLUB', TEST_CLUB_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_CLUB').AsString = UPDATED_CLUB_NAME, 'Updated CLUB name stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_CLUB').AsString := TEST_CLUB_NAME;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_CLUB', TEST_CLUB_CODE], ['OLD_CD_CLUB', TEST_CLUB_CODE]], DataSet));
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
                       [['CD_CLUB', TEST_CLUB_CODE]],
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
      await(TDB.Delete(LOCAL_PATH, [['CD_CLUB', TEST_CLUB_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CLUB', TEST_CLUB_CODE]],
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
