unit TestUniversities;

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
   TTestUniversities = class(TObject)
   private
      const LOCAL_PATH                 = '/universities';
      const TEST_UNIVERSITY_CODE       = 'UT_UNI_0001';
      const TEST_UNIVERSITY_NAME       = 'Unit Test University';
      const TEST_CONFERENCE_CODE       = 'UTC01';
      const TEST_DIVISION_CODE         = 'DIVISION';
      const TEST_RANKING               = 42;
      const TEST_COUNTRY_CODE          = 'UTC';
      const TEST_STATE_CODE            = 'UTS';
      const UPDATED_UNIVERSITY_NAME    = 'Unit Test University - Updated';
      const UPDATED_DIVISION_CODE      = 'DIVISION2';
      const UPDATED_RANKING            = 24;
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillUniversityData(ADataSet :TWebClientDataSet; const AName, ADivision :string; const ARanking :Integer);
      [async] function HasTestUniversity:Boolean;
      [async] procedure EnsureTestUniversityExists;
      [async] procedure DeleteTestUniversityIfExists;
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

{ TTestUniversities }

function TTestUniversities.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_UNIVERSITY';
   NewField.Size := 32;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_UNIVERSITY';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_CONFERENCE';
   NewField.Size := 5;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_DIVISION';
   NewField.Size := 8;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName := 'RANKING';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

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

   Result.Active := True;
end;

procedure TTestUniversities.FillUniversityData(ADataSet :TWebClientDataSet; const AName, ADivision :string; const ARanking :Integer);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_UNIVERSITY').AsString := TEST_UNIVERSITY_CODE;
   ADataSet.FieldByName('DS_UNIVERSITY').AsString := AName;
   ADataSet.FieldByName('CD_CONFERENCE').AsString := TEST_CONFERENCE_CODE;
   ADataSet.FieldByName('CD_DIVISION').AsString := ADivision;
   ADataSet.FieldByName('RANKING').AsInteger := ARanking;
   ADataSet.FieldByName('CD_COUNTRY').AsString := TEST_COUNTRY_CODE;
   ADataSet.FieldByName('CD_STATE').AsString := TEST_STATE_CODE;
   ADataSet.Post;
end;

[async] function TTestUniversities.HasTestUniversity:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestUniversities.EnsureTestUniversityExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestUniversity()) then Exit;

   DataSet := CreateDataSet;
   try
      FillUniversityData(DataSet,
                         TEST_UNIVERSITY_NAME,
                         TEST_DIVISION_CODE,
                         TEST_RANKING);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestUniversityExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestUniversities.DeleteTestUniversityIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestUniversities.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestUniversityIfExists());

   DataSet := CreateDataSet;
   try
      FillUniversityData(DataSet,
                         TEST_UNIVERSITY_NAME,
                         TEST_DIVISION_CODE,
                         TEST_RANKING);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestUniversity()), 'Inserted university not found afterwards');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestUniversityExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', IntToStr(1)],
                         ['SearchText', TEST_UNIVERSITY_CODE],
                         ['OrderField', '']],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Select returned at least one row');
      Assert.IsTrue(DataSet.FieldByName('CD_UNIVERSITY').AsString = TEST_UNIVERSITY_CODE, 'University code matches in load');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUniversityExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_UNIVERSITY').AsString = TEST_UNIVERSITY_NAME, 'University name matches');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestUniversityExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_UNIVERSITY', 'DS_UNIVERSITY', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.IndexOfName(TEST_UNIVERSITY_CODE) >= 0, 'Test university present in GetAll list');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestUniversityExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_UNIVERSITY').AsString := UPDATED_UNIVERSITY_NAME;
      DataSet.FieldByName('CD_DIVISION').AsString := UPDATED_DIVISION_CODE;
      DataSet.FieldByName('RANKING').AsInteger := UPDATED_RANKING;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE],
                           ['OLD_CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_UNIVERSITY').AsString = UPDATED_UNIVERSITY_NAME, 'Updated university name stored');
      Assert.IsTrue(DataSet.FieldByName('CD_DIVISION').AsString = UPDATED_DIVISION_CODE, 'Updated division stored');
      Assert.IsTrue(DataSet.FieldByName('RANKING').AsInteger = UPDATED_RANKING, 'Updated ranking stored');

      DataSet.Edit;
      DataSet.FieldByName('DS_UNIVERSITY').AsString := TEST_UNIVERSITY_NAME;
      DataSet.FieldByName('CD_DIVISION').AsString := TEST_DIVISION_CODE;
      DataSet.FieldByName('RANKING').AsInteger := TEST_RANKING;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE],
                        ['OLD_CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestUniversityExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test university should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestDelete;
var ExceptMsg :string;
    DataSet   :TWebClientDataSet;
begin
   await(EnsureTestUniversityExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_UNIVERSITY', TEST_UNIVERSITY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'University successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestUniversities.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestUniversities);

end.
