unit TestConferences;

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
   TTestConferences = class(TObject)
   private
      const LOCAL_PATH = '/conferences';
      const TEST_CONFERENCE_CODE = 'UTCF1';
      const TEST_DESCRIPTION = 'Unit Test Conference';
      const UPDATED_DESCRIPTION = 'UT Conf - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillConferenceData(ADataSet :TWebClientDataSet; const ADescription :string);
      [async] function HasTestConference:Boolean;
      [async] procedure EnsureTestConferenceExists;
      [async] procedure DeleteTestConferenceIfExists;
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

{ TTestConferences }

function TTestConferences.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_CONFERENCE';
   NewField.Size := 5;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_CONFERENCE';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestConferences.FillConferenceData(ADataSet :TWebClientDataSet; const ADescription :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_CONFERENCE').AsString := TEST_CONFERENCE_CODE;
   ADataSet.FieldByName('DS_CONFERENCE').AsString := ADescription;
   ADataSet.Post;
end;

[async] function TTestConferences.HasTestConference:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestConferences.EnsureTestConferenceExists;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestConference()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillConferenceData(DataSet, TEST_DESCRIPTION);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestConferenceExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestConferences.DeleteTestConferenceIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_CONFERENCE', TEST_CONFERENCE_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestConferences.TestInsert;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestConferenceIfExists());

   DataSet := CreateDataSet;
   try
      FillConferenceData(DataSet, TEST_DESCRIPTION);
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

[Test] [async] procedure TTestConferences.TestLoad;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
    Count :Integer;
begin
   await(EnsureTestConferenceExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'],
                         ['SearchText', 'Unit Test'],
                         ['OrderField', '']],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_CONFERENCE', TEST_CONFERENCE_CODE, []), 'Test conference located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestConferences.TestGetOne;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestConferenceExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_CONFERENCE').AsString = TEST_DESCRIPTION, 'Conference description matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestConferences.TestGetAll;
var Items :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestConferenceExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_CONFERENCE', 'DS_CONFERENCE', []));
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

[Test] [async] procedure TTestConferences.TestUpdate;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestConferenceExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_CONFERENCE').AsString := UPDATED_DESCRIPTION;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_CONFERENCE', TEST_CONFERENCE_CODE], ['OLD_CD_CONFERENCE', TEST_CONFERENCE_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_CONFERENCE').AsString = UPDATED_DESCRIPTION, 'Updated description stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_CONFERENCE').AsString := TEST_DESCRIPTION;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_CONFERENCE', TEST_CONFERENCE_CODE], ['OLD_CD_CONFERENCE', TEST_CONFERENCE_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestConferences.TestIsReferenced;
var DataSet :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg :string;
    TextMessage :string;
begin
   await(EnsureTestConferenceExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test conference should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestConferences.TestDelete;
var DataSet :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestConferenceExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_CONFERENCE', TEST_CONFERENCE_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CONFERENCE', TEST_CONFERENCE_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Conference successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestConferences.TestGetOrderByFields;
var Items :TStrings;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestConferences);

end.
