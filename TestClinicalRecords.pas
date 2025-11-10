unit TestClinicalRecords;

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
   TTestClinicalRecords = class(TObject)
   private
      const LOCAL_PATH             = '/clinicalrecord';
      const TEST_USER              = 'PLAYERUS';
      const TEST_USER_NAME         = 'Unit Test Clinical Record';
      const TEST_EMAIL             = 'clinical.record@example.com';
      const TEST_PHONE_NUMBER      = '+1-555-000-1234';
      const UPDATED_PHONE_NUMBER   = '+1-555-999-4321';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillClinicalRecordData(ADataSet :TWebClientDataSet; const APhoneNumber :string);
      [async] function HasTestClinicalRecord:Boolean;
      [async] procedure EnsureTestClinicalRecordExists;
      [async] procedure DeleteTestClinicalRecordIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestCheckExistence;
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

{ TTestClinicalRecords }

function TTestClinicalRecords.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_USER';
   NewField.Size        := 70;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_PROFILE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'BIRTH_DATE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName   := 'CURRENT_AGE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PHONE_NUMBER';
   NewField.Size        := 30;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'EMAIL';
   NewField.Size        := 100;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'STATE';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'PAST_ILLNESSES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'PHARMACOLOGICAL_TREATMENTS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'ALLERGIES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'SIGNIFICANT_INJURIES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'ORTHOPEDIC_PROBLEMS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'FAMILY_HISTORY';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'AUSCULTATION_FINFINDS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'OTHER_CONTROLS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'OBSERVATIONS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestClinicalRecords.FillClinicalRecordData(ADataSet :TWebClientDataSet; const APhoneNumber :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString                      := TEST_USER;
   ADataSet.FieldByName('DS_USER').AsString                      := TEST_USER_NAME;
   ADataSet.FieldByName('IMG_PROFILE').AsString                  := 'ProfileImageData';
   ADataSet.FieldByName('BIRTH_DATE').AsDateTime                 := EncodeDate(1995, 5, 15);
   ADataSet.FieldByName('CURRENT_AGE').AsInteger                 := 29;
   ADataSet.FieldByName('PHONE_NUMBER').AsString                 := APhoneNumber;
   ADataSet.FieldByName('EMAIL').AsString                        := TEST_EMAIL;
   ADataSet.FieldByName('STATE').AsString                        := 'A';
   ADataSet.FieldByName('PAST_ILLNESSES').AsString               := 'None';
   ADataSet.FieldByName('PHARMACOLOGICAL_TREATMENTS').AsString   := 'Vitamin supplements';
   ADataSet.FieldByName('ALLERGIES').AsString                    := 'Pollen';
   ADataSet.FieldByName('SIGNIFICANT_INJURIES').AsString         := 'Sprained ankle in 2022';
   ADataSet.FieldByName('ORTHOPEDIC_PROBLEMS').AsString          := 'None';
   ADataSet.FieldByName('FAMILY_HISTORY').AsString               := 'No significant family history';
   ADataSet.FieldByName('AUSCULTATION_FINFINDS').AsString        := 'Normal';
   ADataSet.FieldByName('OTHER_CONTROLS').AsString               := 'Blood pressure monitored quarterly';
   ADataSet.FieldByName('OBSERVATIONS').AsString                 := 'Athlete in excellent condition';
   ADataSet.Post;
end;

[async] function TTestClinicalRecords.HasTestClinicalRecord:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestClinicalRecords.EnsureTestClinicalRecordExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestClinicalRecord()) then Exit;

   DataSet := CreateDataSet;
   try
      FillClinicalRecordData(DataSet, TEST_PHONE_NUMBER);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestClinicalRecordExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestClinicalRecords.DeleteTestClinicalRecordIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_USER]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestClinicalRecords.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestClinicalRecordIfExists());

   DataSet := CreateDataSet;
   try
      FillClinicalRecordData(DataSet, TEST_PHONE_NUMBER);
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

[Test] [async] procedure TTestClinicalRecords.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestClinicalRecordExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'               ],
                         ['SearchText', 'Clinical Record' ],
                         ['OrderField', 'CD_USER'         ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_USER', TEST_USER, []), 'Test clinical record located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClinicalRecords.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClinicalRecordExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_USER').AsString = TEST_USER_NAME, 'User name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClinicalRecords.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestClinicalRecordExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                LOCAL_PATH+'/getall',
                                'CD_USER',
                                'DS_USER',
                                [['CD_USER', TEST_USER]]));
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

[Test] [async] procedure TTestClinicalRecords.TestCheckExistence;
var DataSet      :TWebClientDataSet;
    ExceptMsg    :string;
    ExistsRecord :Boolean;
    TextMessage  :string;
begin
   (*await(EnsureTestClinicalRecordExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER]],
                       DataSet));
      try
         ExistsRecord := await(Boolean, TDB.CheckExistence(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
            ExistsRecord := False;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in CheckExistence -> '+ExceptMsg);
      Assert.IsTrue(ExistsRecord = True, 'Test clinical record should exist');
   finally
      DataSet.Free;
   end;*)
end;

[Test] [async] procedure TTestClinicalRecords.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClinicalRecordExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('PHONE_NUMBER').AsString := UPDATED_PHONE_NUMBER;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_USER],
                           ['OLD_CD_USER', TEST_USER]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('PHONE_NUMBER').AsString = UPDATED_PHONE_NUMBER, 'Updated phone number stored in database');

      DataSet.Edit;
      DataSet.FieldByName('PHONE_NUMBER').AsString := TEST_PHONE_NUMBER;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['OLD_CD_USER', TEST_USER]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClinicalRecords.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    ExceptMsg    :string;
    TextMessage  :string;
    IsReferenced :Boolean;
begin
   await(EnsureTestClinicalRecordExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
            IsReferenced := True;
         end;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test clinical record should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestClinicalRecords.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestClinicalRecordExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_USER]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Clinical record successfully removed');
   finally
      DataSet.Free;
   end;

   await(EnsureTestClinicalRecordExists());
end;

[Test] [async] procedure TTestClinicalRecords.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                LOCAL_PATH+'/getorderbyfields',
                                'FIELD_NAME',
                                'SHOW_NAME',
                                []));
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestClinicalRecords);

end.
