unit TestUsers;

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
   TTestUsers = class(TObject)
   private
      const LOCAL_PATH          = '/users';
      const TEST_USER_CODE      = 'UT_USER_0001';
      const TEST_EMAIL          = 'unit.test.user@example.com';
      const TEST_FIRST_NAME     = 'Unit';
      const UPDATED_FIRST_NAME  = 'Updated';
      const UPDATED_LAST_NAME   = 'User';
   private
      function CreateUserDataSet:TWebClientDataSet;
      procedure FillUserData(ADataSet :TWebClientDataSet);
      [async] function HasTestUser:Boolean;
      [async] procedure EnsureTestUserExists;
      [async] procedure DeleteTestUserIfExists;
      procedure PrepareSingleRowDataSet(ADataSet :TWebClientDataSet);
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
      [Test] [async] procedure TestGetBasicData;
      [Test] [async] procedure TestLoadAction;
      [Test] [async] procedure TestGetFilterByProfilesUsers;
      [Test] [async] procedure TestGetBasicInfo;
      [Test] [async] procedure TestEmailExists;
      [Test] [async] procedure TestSendInvitation;
      [Test] [async] procedure TestInvitationActive;
      [Test] [async] procedure TestClearInvitation;
   end;
{$M-}

implementation

uses
   senCille.DataManagement;

{ TTestUsers }

function TTestUsers.CreateUserDataSet:TWebClientDataSet;
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
   NewField.FieldName := 'EMAIL';
   NewField.Size := 100;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'CREATED';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'VERIFIED';
   NewField.Size := 1;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'RENEW_VERIFY';
   NewField.Size := 1;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_USER_ROLE';
   NewField.Size := 12;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'TITLE';
   NewField.Size := 4;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'FIRST_NAME';
   NewField.Size := 30;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'LAST_NAME';
   NewField.Size := 40;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_USER';
   NewField.Size := 70;
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
   NewField.FieldName := 'CD_STATE';
   NewField.Size := 3;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_COUNTRY';
   NewField.Size := 3;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PHONE_NUMBER';
   NewField.Size := 20;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PREFERRED_LANGUAGE';
   NewField.Size := 2;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_METRICS';
   NewField.Size := 1;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'NOTES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_PROFILE';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_COUNTRY';
   NewField.Size := 40;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_STATE';
   NewField.Size := 40;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestUsers.FillUserData(ADataSet :TWebClientDataSet);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_USER_CODE;
   ADataSet.FieldByName('EMAIL').AsString := TEST_EMAIL;
   ADataSet.FieldByName('CREATED').AsDateTime := Now;
   ADataSet.FieldByName('VERIFIED').AsString := 'N';
   ADataSet.FieldByName('RENEW_VERIFY').AsString := 'N';
   ADataSet.FieldByName('CD_USER_ROLE').AsString := 'PLAYER';
   ADataSet.FieldByName('TITLE').AsString := 'Mr';
   ADataSet.FieldByName('FIRST_NAME').AsString := TEST_FIRST_NAME;
   ADataSet.FieldByName('LAST_NAME').AsString := 'User';
   ADataSet.FieldByName('DS_USER').AsString := 'Unit Test User';
   ADataSet.FieldByName('ADDRESS_LN_1').AsString := '123 Test Street';
   ADataSet.FieldByName('ADDRESS_LN_2').AsString := 'Suite 100';
   ADataSet.FieldByName('CITY').AsString := 'Madrid';
   ADataSet.FieldByName('POSTAL_CODE').AsString := '28001';
   ADataSet.FieldByName('PROVINCE').AsString := 'Madrid';
   ADataSet.FieldByName('CD_STATE').AsString := 'MD';
   ADataSet.FieldByName('CD_COUNTRY').AsString := 'ES';
   ADataSet.FieldByName('PHONE_NUMBER').AsString := '+34 600 000 000';
   ADataSet.FieldByName('PREFERRED_LANGUAGE').AsString := 'ES';
   ADataSet.FieldByName('CD_METRICS').AsString := 'M';
   ADataSet.FieldByName('NOTES').AsString := 'User created for automated unit testing.';
   ADataSet.FieldByName('IMG_PROFILE').AsString := 'NoImage';
   ADataSet.FieldByName('DS_COUNTRY').AsString := 'Spain';
   ADataSet.FieldByName('DS_STATE').AsString := 'Madrid';
   ADataSet.Post;
end;

procedure TTestUsers.PrepareSingleRowDataSet(ADataSet :TWebClientDataSet);
begin
   if not ADataSet.Active then begin
      ADataSet.Active := True;
   end;
   if not ADataSet.IsEmpty then begin
      ADataSet.EmptyDataSet;
   end;
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_USER_CODE;
   ADataSet.FieldByName('EMAIL').AsString := TEST_EMAIL;
   ADataSet.Post;
end;

[async] function TTestUsers.HasTestUser:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateUserDataSet;
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

[async] procedure TTestUsers.EnsureTestUserExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestUser()) then begin
      Exit;
   end;

   DataSet := CreateUserDataSet;
   try
      FillUserData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestUserExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestUsers.DeleteTestUserIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestUsers.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestUserIfExists());

   DataSet := CreateUserDataSet;
   try
      FillUserData(DataSet);
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

[Test] [async] procedure TTestUsers.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['PageNumber', '1'],
                                    ['SearchText', 'Unit Test User'],
                                    ['OrderField', '']],
                                   DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_USER', TEST_USER_CODE, []), 'Test user located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
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
      Assert.IsTrue(DataSet.FieldByName('EMAIL').AsString = TEST_EMAIL, 'User email matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

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

[Test] [async] procedure TTestUsers.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := UPDATED_FIRST_NAME;
      DataSet.FieldByName('LAST_NAME').AsString := UPDATED_LAST_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('FIRST_NAME').AsString = UPDATED_FIRST_NAME, 'Updated first name stored');
      Assert.IsTrue(DataSet.FieldByName('LAST_NAME').AsString = UPDATED_LAST_NAME, 'Updated last name stored');

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := TEST_FIRST_NAME;
      DataSet.FieldByName('LAST_NAME').AsString := 'User';
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
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
      Assert.IsTrue(IsReferenced = False, 'Test user should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateUserDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'User successfully removed');
   finally
      DataSet.Free;
   end;

   await(EnsureTestUserExists());
end;

[Test] [async] procedure TTestUsers.TestGetOrderByFields;
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

[Test] [async] procedure TTestUsers.TestGetBasicData;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['Language', 'EN'],
                                    ['SearchText', 'Unit Test']],
                                   DataSet,
                                   '/getbasicdata'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetBasicData -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'GetBasicData executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestLoadAction;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['PageNumber', '1'],
                                    ['SearchText', '']],
                                   DataSet,
                                   '/load'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load action -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'Load action executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestGetFilterByProfilesUsers;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['Filter', 'ALL']],
                                   DataSet,
                                   '/getfilterbyprofilesusers'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetFilterByProfilesUsers -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'GetFilterByProfilesUsers executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestGetBasicInfo;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH+'/getbasicinfo',
                          [['CD_USER', TEST_USER_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetBasicInfo -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Basic info returned');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestEmailExists;
var ExistsEmail :Boolean;
    ExceptMsg   :string;
begin
   await(EnsureTestUserExists());

   try
      ExistsEmail := await(Boolean, TDB.GetBoolean(LOCAL_PATH, '/emailexists', [['EMAIL', TEST_EMAIL]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         ExistsEmail := False;
      end;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in EmailExists -> '+ExceptMsg);
   Assert.IsTrue(ExistsEmail, 'Email should exist for the test user');
end;

[Test] [async] procedure TTestUsers.TestSendInvitation;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      PrepareSingleRowDataSet(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/sendinvitation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in SendInvitation -> '+ExceptMsg);

      PrepareSingleRowDataSet(DataSet);
      await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]], DataSet, '/clearinvitation'));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestInvitationActive;
var DataSet   :TWebClientDataSet;
    IsActive  :Boolean;
    ExceptMsg :string;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      PrepareSingleRowDataSet(DataSet);
      await(TDB.Insert(LOCAL_PATH, DataSet, '/sendinvitation'));

      try
         IsActive := await(Boolean, TDB.GetBoolean(LOCAL_PATH, '/invitationactive', [['CD_USER', TEST_USER_CODE]]));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
            IsActive := False;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InvitationActive -> '+ExceptMsg);
      Assert.IsTrue(IsActive, 'Invitation should be active after sending');

      PrepareSingleRowDataSet(DataSet);
      await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]], DataSet, '/clearinvitation'));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUsers.TestClearInvitation;
var DataSet    :TWebClientDataSet;
    ExceptMsg  :string;
    Invitation :Boolean;
begin
   await(EnsureTestUserExists());

   DataSet := CreateUserDataSet;
   try
      PrepareSingleRowDataSet(DataSet);
      await(TDB.Insert(LOCAL_PATH, DataSet, '/sendinvitation'));

      PrepareSingleRowDataSet(DataSet);
      try
         await(TDB.Update(LOCAL_PATH, [['CD_USER', TEST_USER_CODE]], DataSet, '/clearinvitation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in ClearInvitation -> '+ExceptMsg);

      Invitation := await(Boolean, TDB.GetBoolean(LOCAL_PATH, '/invitationactive', [['CD_USER', TEST_USER_CODE]]));
      Assert.IsTrue(not Invitation, 'Invitation should be cleared');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestUsers);

end.
